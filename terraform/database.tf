/**
 * RDS Aurora Serverless v2関連リソース
 */

# DB サブネットグループ
resource "aws_db_subnet_group" "this" {
  name       = "${var.service_prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_c.id]

  tags = {
    Name = "${var.service_prefix}-db-subnet-group"
  }
}

# Aurora Serverless v2 クラスター
resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.service_prefix}-aurora-cluster"
  engine             = "aurora-postgresql"
  engine_version     = "16.4" # PostgreSQL Serverless v2対応のエンジンバージョン
  # serverless v2では、プロビジョン°クラスター内で
  # サーバーレスインスタンスを運用するため、engine_modeはprovisioned
  engine_mode   = "provisioned"
  database_name = local.db_config.name

  # データベース認証情報の設定
  master_username = local.db_config.username
  master_password = local.db_config.password

  backup_retention_period   = 30 # バックアップSNは30日間保持
  preferred_backup_window   = "03:00-04:00"
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.service_prefix}-final-snapshot"
  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.db.id]
  storage_encrypted         = true

  # Serverless v2向け設定
  serverlessv2_scaling_configuration {
    min_capacity = 0.5 # 最小容量 (0.5 ACU)
    max_capacity = 1.0 # 最大容量 (1.0 ACU)
  }

  tags = {
    Name = "${var.service_prefix}-aurora-serverless-cluster"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Aurora Serverless v2 インスタンス（最小構成なので1つのみ）
resource "aws_rds_cluster_instance" "main" {
  identifier           = "${var.service_prefix}-aurora-serverless"
  cluster_identifier   = aws_rds_cluster.this.id
  instance_class       = "db.serverless" # Serverless v2用インスタンスクラス
  engine               = aws_rds_cluster.this.engine
  engine_version       = aws_rds_cluster.this.engine_version
  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible  = false

  tags = {
    Name = "${var.service_prefix}-aurora-serverless"
  }
} 