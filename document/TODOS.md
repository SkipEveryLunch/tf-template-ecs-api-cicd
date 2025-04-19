このTerraformリソースはApplyするだけではなく
追加の操作が必要です。

# 1. GitHubとのコネクション設定

GitHubとのコネクション自体はTerraformの`aws_codestarconnections_connection`リソースで定義。だが接続プロバイダーとの認証完了（GitHub Appのインストール＆承認）はコンソール操作が必須

## 設定手順

1. Terraformで`aws_codestarconnections_connection`リソースを適用

2. 適用後、AWSマネジメントコンソールで以下の操作を実行
   - Developer Tools → Settings → Connections を開く
   - 作成された接続（`github-connection`）を選択
   - 「Update pending connection」をクリック
   - 「Connect to GitHub → Authorize AWS Connector for GitHub」を実行

3. 認証完了後、接続のステータスが「AVAILABLE」に変更されることを確認
