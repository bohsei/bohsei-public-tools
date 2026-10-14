param(
    [ValidateSet('Check','Update')]
    [string]$Mode = 'Update',
    [string]$SourcePath = ''
)

# Bohsei MD-Net / JEITA NEC SSL CA update (2026-10).
# This script NEVER downloads or embeds certificates.
# Obtain cacerts directly from NEC, then verify SHA-256.
# Run only when MD-Net ordering and scheduled transfers are stopped.

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$TargetFolder = 'C:\b2bex\b2bexclient'
$TargetPath = Join-Path $TargetFolder 'cacerts'
$BackupFolder = Join-Path $TargetFolder 'cacerts_backup'
$ExpectedSha = '6645F9C7B4BD13CDAD8F79EDDDDB57F776C90E5079B261D4A675DB2C3F31CC50'
$LogDir = Join-Path $env:LOCALAPPDATA 'Bohsei\MDNetCertUpdate'
$Started = $false
$ExitCode = 1

function Get-Hash([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToUpperInvariant()
}

function Assert-Target {
    if (-not (Test-Path -LiteralPath $TargetFolder -PathType Container)) {
        throw "MD-Netのインストール先が見つかりません: $TargetFolder"
    }
    if (-not (Test-Path -LiteralPath $TargetPath -PathType Leaf)) {
        throw "既存cacertsがありません。新規作成せず中止します: $TargetPath"
    }
    $bytes = [System.IO.File]::ReadAllBytes($TargetPath)
    if ($bytes.Length -lt 4 -or $bytes[0] -ne 254 -or $bytes[1] -ne 237 -or $bytes[2] -ne 254 -or $bytes[3] -ne 237) {
        throw '既存cacertsがJKS形式ではありません。システム管理者に連絡してください。'
    }
}

function Assert-NotRunning {
    try {
        $running = @(Get-CimInstance Win32_Process -Filter "Name='java.exe' OR Name='javaw.exe' OR Name='B2BEX_EBMS_CLIENT.EXE'" -ErrorAction Stop |
            Where-Object {
                ($_.Name -ieq 'B2BEX_EBMS_CLIENT.EXE') -or
                ([string]$_.CommandLine -match '(?i)(b2bexclient|B2BEX_EBMS|\\b2bex\\b)')
            })
    } catch {
        throw ('通信クライアントの起動状態を検査できません: ' + $_.Exception.Message)
    }
    if ($running.Count -gt 0) {
        foreach ($proc in $running) {
            Write-Host ("実行中の可能性: {0} PID={1}" -f $proc.Name, $proc.ProcessId) -ForegroundColor Yellow
        }
        throw '通信プログラムが動作しているため、安全のため中止します。'
    }
}

function Find-Source {
    if (-not [string]::IsNullOrWhiteSpace($SourcePath)) {
        return $SourcePath
    }

    # Prefer a NEC-provided cacerts located alongside the downloaded launcher.
    $candidate = Join-Path $PSScriptRoot 'cacerts'
    if ((Test-Path -LiteralPath $candidate -PathType Leaf) -and
        -not [System.IO.Path]::GetFullPath($candidate).Equals(
            [System.IO.Path]::GetFullPath($TargetPath),
            [System.StringComparison]::OrdinalIgnoreCase)) {
        return $candidate
    }

    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'NECから配布された新しいcacertsを選択してください'
    $dialog.Filter = 'cacerts (cacerts)|cacerts|All files (*.*)|*.*'
    $dialog.FilterIndex = 1
    $dialog.CheckFileExists = $true
    $dialog.Multiselect = $false
    $dialog.InitialDirectory = [Environment]::GetFolderPath('UserProfile')
    $result = $dialog.ShowDialog()
    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        throw 'ファイル選択をキャンセルしました。何も変更していません。'
    }
    return $dialog.FileName
}

function Update-Cert {
    Assert-Target
    $before = Get-Hash $TargetPath
    Write-Host "対象: $TargetPath"
    Write-Host "現在のSHA-256: $before"
    if ($before -eq $ExpectedSha) {
        Write-Host 'すでに更新済みです。変更不要です。' -ForegroundColor Green
        return 0
    }
    if ($Mode -eq 'Check') {
        Write-Host '未更新、または配布版と異なるファイルです。現在のファイルは変更していません。' -ForegroundColor Yellow
        return 10
    }

    $source = Find-Source
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "配布ファイルが見つかりません: $source"
    }
    $fullSource = [System.IO.Path]::GetFullPath($source)
    $fullTarget = [System.IO.Path]::GetFullPath($TargetPath)
    if ($fullSource.Equals($fullTarget,[System.StringComparison]::OrdinalIgnoreCase)) {
        throw '元のcacertsを更新ファイルとして指定できません。'
    }

    $suppliedHash = Get-Hash $source
    if ($suppliedHash -ne $ExpectedSha) {
        throw "選択したファイルのSHA-256がNEC配布版と一致しません。更新を禁止します。実際: $suppliedHash"
    }

    Write-Host ''
    Write-Host '【重要】MD-Netの発注処理を終了し、クライアント・定期送受信が停止していることを確認してください。' -ForegroundColor Yellow
    $answer = Read-Host '確認できたら半角 Y を入力（その他は中止）'
    if ($answer -cne 'Y' -and $answer -cne 'y') {
        Write-Host 'キャンセルしました。ファイルは変更していません。'
        return 2
    }

    Assert-NotRunning
    New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null

    $tag = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
    $uid = [Guid]::NewGuid().ToString('N')
    $backup = Join-Path $BackupFolder ("cacerts_{0}_{1}.bak" -f $tag, $uid.Substring(0,8))
    $stage = Join-Path $TargetFolder ('.cacerts_new_' + $uid + '.tmp')
    $restoreStage = Join-Path $TargetFolder ('.cacerts_restore_' + $uid + '.tmp')
    Write-Host "バックアップ: $backup"

    try {
        Copy-Item -LiteralPath $TargetPath -Destination $backup -ErrorAction Stop
        if ((Get-Hash $backup) -ne $before) {
            throw 'バックアップ照合失敗。既存ファイルは変更していません。'
        }
        Copy-Item -LiteralPath $source -Destination $stage -ErrorAction Stop
        if ((Get-Hash $stage) -ne $ExpectedSha) {
            throw '置換予定ファイルの照合に失敗しました。'
        }
        Assert-NotRunning
        if ((Get-Hash $TargetPath) -ne $before) {
            throw '開始時から現在のcacertsが変更されました。安全のため中止します。'
        }

        [System.IO.File]::Replace($stage,$TargetPath,$null)
        if ((Get-Hash $TargetPath) -ne $ExpectedSha) {
            throw '置換後のSHA-256照合に失敗しました。'
        }
        Write-Host ''
        Write-Host '【更新成功】cacertsの置換とSHA-256検証が完了しました。' -ForegroundColor Green
        Write-Host "バックアップ: $backup"
        Write-Host 'NEC手順書に従って接続テストを実施し、必ず本番URLに戻してください。' -ForegroundColor Yellow
        return 0
    } catch {
        $failure = $_.Exception.Message
        if ((Test-Path -LiteralPath $backup -PathType Leaf) -and
            (Get-Hash $backup) -eq $before -and
            (Test-Path -LiteralPath $TargetPath -PathType Leaf) -and
            (Get-Hash $TargetPath) -ne $before) {
            try {
                Copy-Item -LiteralPath $backup -Destination $restoreStage -ErrorAction Stop
                [System.IO.File]::Replace($restoreStage,$TargetPath,$null)
                if ((Get-Hash $TargetPath) -ne $before) { throw '復元後の照合失敗' }
                throw ("更新失敗: {0} / 旧ファイルへの自動復旧成功" -f $failure)
            } catch {
                if ((Get-Hash $TargetPath) -ne $before) {
                    throw ("更新・自動復旧失敗。管理者へ連絡してください。バックアップ: {0} / 詳細: {1}" -f $backup, $failure)
                }
                throw ("更新失敗: {0} / 旧ファイルへの自動復旧成功" -f $failure)
            }
        }
        throw ("更新中止: {0} / バックアップ: {1}" -f $failure,$backup)
    } finally {
        foreach ($p in @($stage,$restoreStage)) {
            if (Test-Path -LiteralPath $p -PathType Leaf) {
                Remove-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

try {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    $log = Join-Path $LogDir ("MDNetCertUpdate_{0}_{1}.txt" -f $env:COMPUTERNAME,(Get-Date -Format 'yyyyMMdd_HHmmss'))
    Start-Transcript -LiteralPath $log -ErrorAction Stop | Out-Null
    $Started = $true
    Write-Host '========================================================'
    Write-Host 'MD-Net 2026 SSL証明書更新（望星サイエンス）'
    Write-Host '========================================================'
    Write-Host "モード: $Mode"
    Write-Host "作業記録: $log"
    $ExitCode = Update-Cert
} catch {
    Write-Host ('【エラー】'+$_.Exception.Message) -ForegroundColor Red
    Write-Host 'ファイル状態を確認し、作業記録をシステム管理室へ連絡してください。' -ForegroundColor Yellow
    $ExitCode = 1
} finally {
    if ($Started) { Stop-Transcript | Out-Null }
}
exit $ExitCode
