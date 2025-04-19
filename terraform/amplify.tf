/**
 * AWS Amplify関連リソース
 */

# Amplifyアプリ
resource "aws_amplify_app" "this" {
  name                        = "${var.service_prefix}-nextjs-app"
  repository                  = var.github_repository
  access_token                = var.github_token
  enable_branch_auto_build    = true
  enable_branch_auto_deletion = true

  # Basic認証を設定しない
  enable_basic_auth = false

  # 環境変数
  environment_variables = {
    NEXT_PUBLIC_API_BASE_URL = var.api_base_url
    _CUSTOM_IMAGE            = "node:${var.node_version}"
  }
  platform = "WEB_COMPUTE"

  tags = {
    Name = "${var.service_prefix}-nextjs-app"
  }
}

# メインブランチの設定
resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.this.id
  branch_name = "main"
  framework   = "Next.js - SSR"
  stage       = "PRODUCTION"
}

# カスタムドメインの設定
resource "aws_amplify_domain_association" "this" {
  app_id      = aws_amplify_app.this.id
  domain_name = var.domain_name

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "" # ルートドメインに設定
  }
} 