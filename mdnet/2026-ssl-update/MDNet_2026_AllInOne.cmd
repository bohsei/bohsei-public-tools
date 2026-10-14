@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "BOHSEI_MDNET_SELF=%~f0"
title MD-Net 2026 SSL Certificate Update
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $txt=[IO.File]::ReadAllText($env:BOHSEI_MDNET_SELF,[Text.Encoding]::UTF8); $mark='#=BOHSEI_MDNET_PS=#'; $pos=$txt.LastIndexOf($mark); if($pos -lt 0){throw 'Installer script missing'}; & ([ScriptBlock]::Create($txt.Substring($pos+$mark.Length)))"
set "BOHSEI_MDNET_EXIT=%ERRORLEVEL%"
if not "%BOHSEI_MDNET_EXIT%"=="0" (
  echo.
  echo MD-Net SSL update did not finish successfully. Please contact IT support.
  pause
)
exit /b %BOHSEI_MDNET_EXIT%
#=BOHSEI_MDNET_PS=#
# MD-Net SSL 2026 / Bohsei public one-file installer.
# 2026-10-14 | Windows PowerShell 5.1 | JKS trusted CA only.
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$TargetDir = 'C:\b2bex\b2bexclient'
$Target = Join-Path $TargetDir 'cacerts'
$BackupDir = Join-Path $TargetDir 'cacerts_backup'
$LogDir = Join-Path $env:LOCALAPPDATA 'Bohsei\MDNetCertUpdate'
$Expected = '6645F9C7B4BD13CDAD8F79EDDDDB57F776C90E5079B261D4A675DB2C3F31CC50'
$Payload = @'
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
HFN0YXJmaWVsZCBUZWNobm9sb2dpZXMsIEluYy4xMjAwBgNVBAMTKVN0YXJmaWVsZCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAtIEcyMB4XDTA5MDkwMTAwMDAwMFoXDTM3MTIzMTIzNTk1OVowgY8x
CzAJBgNVBAYTAlVTMRAwDgYDVQQIEwdBcml6b25hMRMwEQYDVQQHEwpTY290dHNkYWxlMSUwIwYDVQQKExxTdGFyZmllbGQgVGVjaG5vbG9naWVzLCBJbmMuMTIwMAYDVQQDEylTdGFyZmllbGQgUm9vdCBD
ZXJ0aWZpY2F0ZSBBdXRob3JpdHkgLSBHMjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL3twQP89o/8ArFvW59I2Z154qK3A2FWGMNHttfKPTUuiUP3oWmb3ooa/RMgnLRJdzIpVv257IzdIvpy
3Cdhl+72WoTsbhm5iSzchFvVdPtrX8WJpRBSiUZV9Lh1HOZ/5FSuS/hVclcCGfgXcVnrHigHdMWdSL5stPSksPNkN3mSwOxGXn/hbVNMYq/NHwtjuzqd+/x5AJhhdM8mgkBj87JyahkNmcrUDnXMN/uLicFZ
8WJ/X7NfZTD4p7dNdloedl40wOiWVpmKs/B/pM293DIxfJHP4F8R+GuqSVzRmZTRouNjWwl2tVZi4Ut0HZbUJtQIBFnQmA4O5t78w+wfkPECAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8E
BAMCAQYwHQYDVR0OBBYEFHwMMh+n2TB/xH1oo2Kooc6rB1snMA0GCSqGSIb3DQEBCwUAA4IBAQARWfolTwNvlJk7mh+ChTnUdgWUXuEok21iXQnCoKjUsHU48TRqneSfioYmUeYs0cYtbpUgSpIB7LiKZ3sx
4mcujJUDJi5DnUox9g61DLu34jd/IroAow57UvtruzvE03lRTs2Q9GcHGcg8RnoNAX3FWOdt5oUwF5okxBDgBPfg8n/Uqgr/Qh037ZTlZFkSIHc40zI+OIF1lnP6aI+xy84fxez6nH7PfrHxBy22/L/KpL/Q
lwVKvOoYKAKQvVR4CSFx09F9HdkWsKlhPdAKACL8x3vLCWRFCztAgfd9fDL1mMpYjn0q7pBZc2T5NnReJaH1ZgUufzkVqSr7UIuOhWn0jQnZq3iacacw/9k0r2Df4NRT5Us=
'@
$Temp = Join-Path $env:TEMP ('BohseiMDNet_' + [guid]::NewGuid().ToString('N') + '.jks')
$TranscriptStarted = $false
$ReturnCode = 1

function HashOf([string]$p) {
    return (Get-FileHash -LiteralPath $p -Algorithm SHA256 -ErrorAction Stop).Hash.ToUpperInvariant()
}

function Popup([string]$title, [string]$message, [string]$buttons = 'OK', [string]$icon = 'Information') {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    return [System.Windows.Forms.MessageBox]::Show(
        $message,$title,
        [System.Windows.Forms.MessageBoxButtons]::$buttons,
        [System.Windows.Forms.MessageBoxIcon]::$icon,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button1)
}

function EnsureTarget {
    if (-not (Test-Path -LiteralPath $Target -PathType Leaf)) {
        throw ('MD-Netが見つかりません。更新せず中止しました。対象: ' + $Target)
    }
    $data = [IO.File]::ReadAllBytes($Target)
    if ($data.Length -lt 4 -or $data[0] -ne 254 -or $data[1] -ne 237 -or $data[2] -ne 254 -or $data[3] -ne 237) {
        throw '既存のcacertsが想定するJKS形式と異なるため、更新を中止しました。'
    }
}

function EnsureIdle {
    # Extra guard: scheduled sends/receives still need to be stopped by the operator.
    $procs = @(Get-CimInstance Win32_Process -Filter "Name='java.exe' OR Name='javaw.exe' OR Name='cmd.exe' OR Name='wscript.exe' OR Name='B2BEX_EBMS_CLIENT.EXE'" -ErrorAction Stop | Where-Object {
        $_.Name -ieq 'B2BEX_EBMS_CLIENT.EXE' -or [string]$_.CommandLine -match '(?i)([\\/]b2bex[\\/]|b2bexclient|B2BEX_EBMS|[\\/]ediclient[\\/])'
    })
    if ($procs.Count -gt 0) {
        throw 'MD-Net関連の処理が起動しているため、中止しました。画面と定期送受信を終了してください。'
    }
}

function Install {
    EnsureTarget
    [IO.File]::WriteAllBytes($Temp, [Convert]::FromBase64String($Payload))
    if ((HashOf $Temp) -ne $Expected) {
        throw '内蔵したNEC配布ファイルの整合性が確認できません。更新せず中止しました。'
    }
    $before = HashOf $Target
    Write-Host "対象: $Target"
    Write-Host "更新前SHA-256: $before"
    if ($before -eq $Expected) {
        Write-Host '更新済みです。変更不要です。' -ForegroundColor Green
        [void](Popup 'MD-Net 証明書更新' ('このパソコンは更新済みです。' + [Environment]::NewLine + '何も変更していません。' + [Environment]::NewLine + 'MD-Netの通信確認は別途必要です。'))
        return 0
    }
    $nl = [Environment]::NewLine
    $msg = 'MD-Netの発注作業を終えましたか？' + $nl + $nl +
           'MD-Netの画面を閉じ、定期送受信も停止してください。' + $nl +
           '証明書のみ更新し、発注データや通信先は変更しません。' + $nl + $nl +
           '更新前のファイルは自動保存します。' + $nl + $nl +
           '「はい」で更新　「いいえ」で中止'
    $answer = Popup 'MD-Net 証明書更新・確認' $msg 'YesNo' 'Question'
    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) { return 2 }
    EnsureIdle
    New-Item -ItemType Directory -Path $BackupDir -Force -ErrorAction Stop | Out-Null
    $id = [guid]::NewGuid().ToString('N')
    $tag = Get-Date -Format 'yyyyMMdd_HHmmss_fff'
    $bak = Join-Path $BackupDir ('cacerts_' + $tag + '_' + $id.Substring(0,8) + '.bak')
    $stage = Join-Path $TargetDir ('.cacerts_new_' + $id + '.tmp')
    $restore = Join-Path $TargetDir ('.cacerts_restore_' + $id + '.tmp')
    try {
        Copy-Item -LiteralPath $Target -Destination $bak -ErrorAction Stop
        if ((HashOf $bak) -ne $before) { throw 'バックアップ検証失敗（元ファイルは未変更）。' }
        Copy-Item -LiteralPath $Temp -Destination $stage -ErrorAction Stop
        if ((HashOf $stage) -ne $Expected) { throw '置換用ファイルの検証に失敗しました。' }
        EnsureIdle
        if ((HashOf $Target) -ne $before) { throw '操作中に元のcacertsが変更されました。安全のため中止しました。' }
        [IO.File]::Replace($stage,$Target,$null)
        if ((HashOf $Target) -ne $Expected) { throw '置換後のSHA-256が一致しません。' }
        Write-Host "バックアップ: $bak"
        Write-Host '証明書ファイルの更新が成功しました。' -ForegroundColor Green
        [void](Popup 'MD-Net 証明書更新・成功' (
            '証明書の更新が完了しました。' + $nl + $nl +
            'この画面の成功はファイル更新の結果です。' + $nl +
            'システム管理室でMD-Netの接続確認が必要です。' + $nl + $nl +
            '確認が済むまで他の人に配布しないでください。'))
        return 0
    } catch {
        $original = $_.Exception.Message
        $recovery = '元のファイルは変更されていない可能性があります。'
        try {
            if ((Test-Path -LiteralPath $bak -PathType Leaf) -and (HashOf $bak) -eq $before -and
                (Test-Path -LiteralPath $Target -PathType Leaf) -and (HashOf $Target) -ne $before) {
                Copy-Item -LiteralPath $bak -Destination $restore -ErrorAction Stop
                [IO.File]::Replace($restore,$Target,$null)
                if ((HashOf $Target) -ne $before) { throw '復元後のファイルが元と一致しません。' }
                $recovery = '更新前の状態への自動復旧に成功しました。'
            }
        } catch {
            $recovery = '自動復旧に失敗しました。バックアップを使い、管理者が確認してください。'
        }
        throw ('更新失敗: '+ $original + ' / ' + $recovery + ' / バックアップ: ' + $bak)
    } finally {
        foreach ($path in @($stage,$restore)) {
            if (Test-Path -LiteralPath $path -PathType Leaf) { Remove-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue }
        }
    }
}

try {
    New-Item -ItemType Directory -Path $LogDir -Force -ErrorAction Stop | Out-Null
    $log = Join-Path $LogDir ('MDNetUpdate_' + $env:COMPUTERNAME + '_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff') + '.txt')
    Start-Transcript -LiteralPath $log -ErrorAction Stop | Out-Null
    $TranscriptStarted = $true
    Write-Host 'MD-Net SSL証明書更新 (2026)'
    Write-Host ('PC: ' + $env:COMPUTERNAME)
    Write-Host ('ログ: ' + $log)
    $ReturnCode = Install
    if ($ReturnCode -eq 2) {
        [void](Popup 'MD-Net 証明書更新・中止' '更新はキャンセルされました。ファイルは変更していません。')
    }
} catch {
    Write-Host ('更新エラー: ' + $_.Exception.Message) -ForegroundColor Red
    try {
        $message = $_.Exception.Message
        if ($message.Length -gt 260) { $message = $message.Substring(0,260) + '...' }
        [void](Popup 'MD-Net 証明書更新・エラー' (
            '更新できませんでした。' + [Environment]::NewLine +
            '発注処理はせず、システム管理室に連絡してください。' + [Environment]::NewLine +
            '原因: ' + $message + [Environment]::NewLine +
            'ログ: ' + $log) 'OK' 'Error')
    } catch { }
    $ReturnCode = 1
} finally {
    if ($TranscriptStarted) { Stop-Transcript | Out-Null }
    if (Test-Path -LiteralPath $Temp -PathType Leaf) { Remove-Item -LiteralPath $Temp -Force -ErrorAction SilentlyContinue }
}
exit $ReturnCode
