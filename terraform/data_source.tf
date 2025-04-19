# Route53関連のデータソース
data "aws_secretsmanager_secret" "hostzone" {
  name = "${var.service_prefix}-hostzone"
}

data "aws_secretsmanager_secret_version" "hostzone" {
  secret_id = data.aws_secretsmanager_secret.hostzone.id
}

data "aws_route53_zone" "this" {
  zone_id = jsondecode(data.aws_secretsmanager_secret_version.hostzone.secret_string)["id"]
}

# データベース関連のデータソース
data "aws_secretsmanager_secret" "db_secret" {
  name = "${var.service_prefix}-db-secrets"
}

# aws_secretsmanager_secretの最新バージョンの詳細を取得
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

# VPNのSSH接続用アドレスをシークレットから取得
data "aws_secretsmanager_secret" "vpn_ssh" {
  name = "${var.service_prefix}-vpn-for-ssh"
}

data "aws_secretsmanager_secret_version" "vpn_ssh" {
  secret_id = data.aws_secretsmanager_secret.vpn_ssh.id
}

locals {
  # ドメイン名の設定（末尾に必ず.がついているのでトリム）
  domain_name = trimsuffix(data.aws_route53_zone.this.name, ".")

  # 完全なサブドメイン名
  subdomain = "${var.api_subdomain_prefix}.${local.domain_name}"

  # データベース認証情報の取得
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)

  # データベース接続情報
  db_config = {
    username = local.db_credentials["username"]
    password = local.db_credentials["password"]
    name     = "app" # デフォルトのDB名はalphanumericな文字列しか指定できないため
  }

  # Prisma用のデータベースURL
  database_url_for_prisma = "postgresql://${local.db_config.username}:${local.db_config.password}@${aws_rds_cluster.this.endpoint}/${local.db_config.name}"

  # ssh接続用に使うVPNのアドレス
  vpn_ssh_data = jsondecode(data.aws_secretsmanager_secret_version.vpn_ssh.secret_string)
  vpn_ssh_ip   = local.vpn_ssh_data["ip-address"]
}
