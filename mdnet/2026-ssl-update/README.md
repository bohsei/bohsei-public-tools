# MD-Net 2026 SSL証明書更新ツール

2026-11-16のB2B-EXCHANGE SSLサーバ証明書切替に向けた、JEITA共通クライアントbyNEC用の更新補助ツールです。

## 管理者による初回試験（一般配布前）

1. MD-Netでの発注業務を終え、送受信クライアントと予約・定期実行を停止してください。
2. **NECから正式に配布された新しい `cacerts` ファイル**を事前に入手してください。この公開GitHubリポジトリには配布していません。
3. [01_MDNet_Update.cmd](./01_MDNet_Update.cmd) を開き、GitHubの **Download raw file** または右クリックの「名前を付けてリンク先を保存」で `01_MDNet_Update.cmd` を取得してください。GitHubのプレビューページを保存しないでください。
4. 保存したCMDをダブルクリックすると、公開したPowerShell本体を固定コミットからダウンロードし、SHA-256で検証後、更新処理が始まります。
5. 画面でNEC配布 `cacerts` を選択してください。配布ファイルのSHA-256が一致しない場合、更新は中止されます。
6. 発注・送受信停止を確認し、`Y` を入力して実行してください。
7. 完了後、NEC手順書に従って `https://testcrgz.b2b-exchange.jp/ebMSv3` で接続テストし、**必ず本番接続URLへ戻して**、本番側の接続テストも行ってください。

## 更新内容

- 対象: `C:\b2bex\b2bexclient\cacerts`
- バックアップ: `C:\b2bex\b2bexclient\cacerts_backup\`
- 作業ログ: `%LOCALAPPDATA%\Bohsei\MDNetCertUpdate\`
- 配布版のSHA-256: `6645F9C7B4BD13CDAD8F79EDDDDB57F776C90E5079B261D4A675DB2C3F31CC50`
- **注意:** 古いファイルに独自の証明書が登録されていた場合、その証明書が配布版で失われる可能性があります。必ず最初の1台で確認してください。

## 配布・安全性

- 実行前に公式配布ファイルを選択する方式であり、証明書そのものはGitHubから取得しません。
- GitHubのソースには認証情報や秘密鍵は含まれていません。
- Windows PowerShell 5.1の構文検証は実施済みですが、実際のMD-Net環境での更新・接続は未検証です。
- GitHub上の`*.cmd`はダブルクリックで直接実行できません。**ダウンロードしてから実行**してください。
- インターネット上の任意の第三者もPublicファイルを取得できます。

[更新本体](./MDNet_2026_Update.ps1) / [クリック起動ファイル](./01_MDNet_Update.cmd)
