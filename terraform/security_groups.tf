/**
 * セキュリティグループ定義
 */

# ALB用のセキュリティグループ
resource "aws_security_group" "alb" {
  name        = "${var.service_prefix}-alb"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.service_prefix}-alb"
  }
}

# インターネットからのHTTPSトラフィック許可
resource "aws_security_group_rule" "alb_ingress_https" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS traffic from internet"
}

# ALBのすべての出力トラフィックを許可
resource "aws_security_group_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# ECS用のセキュリティグループ
resource "aws_security_group" "ecs" {
  name        = "${var.service_prefix}-ecs"
  description = "Security group for ECS Fargate services"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.service_prefix}-ecs"
  }
}

# ALBからのトラフィックを許可
resource "aws_security_group_rule" "ecs_ingress_from_alb" {
  security_group_id        = aws_security_group.ecs.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow traffic from ALB to ECS containers"
}

# VPNからのSSH接続を許可
resource "aws_security_group_rule" "ecs_ingress_ssh_from_vpn" {
  security_group_id = aws_security_group.ecs.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${local.vpn_ssh_ip}/32"]
  description       = "Allow SSH traffic from VPN"
}

# ECSのすべての出力トラフィックを許可
resource "aws_security_group_rule" "ecs_egress" {
  security_group_id = aws_security_group.ecs.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# RDS用のセキュリティグループ
resource "aws_security_group" "db" {
  name        = "${var.service_prefix}-db"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.service_prefix}-db"
  }
}

# ECSからのPostgresトラフィックを許可
resource "aws_security_group_rule" "db_ingress_postgres" {
  security_group_id        = aws_security_group.db.id
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  description              = "Allow PostgreSQL traffic from ECS"
}

# RDSのすべての出力トラフィックを許可
resource "aws_security_group_rule" "db_egress" {
  security_group_id = aws_security_group.db.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# CodeBuild用のセキュリティグループ
resource "aws_security_group" "codebuild" {
  name        = "${var.service_prefix}-codebuild"
  description = "Security group for CodeBuild"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.service_prefix}-codebuild"
  }
}

# CodeBuildのすべての出力トラフィックを許可
resource "aws_security_group_rule" "codebuild_egress" {
  security_group_id = aws_security_group.codebuild.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# RDSのセキュリティグループにCodeBuildからのPostgres接続を許可するルールを追加
resource "aws_security_group_rule" "db_ingress_from_codebuild" {
  security_group_id        = aws_security_group.db.id
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.codebuild.id
  description              = "Allow PostgreSQL traffic from CodeBuild"
}