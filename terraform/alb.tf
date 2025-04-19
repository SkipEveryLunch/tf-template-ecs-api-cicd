/**
 * Application Load Balancer (ALB) と Target Group 定義
 */

# Application Load Balancer
resource "aws_lb" "this" {
  name               = "${var.service_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_c.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.service_prefix}-alb"
  }
}

# HTTP リスナー（HTTPSへリダイレクト）
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS リスナー
resource "aws_lb_listener" "https" {
  count = var.create_certificate ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.main[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  depends_on = [aws_acm_certificate_validation.main]
}

# ターゲットグループ (ECSサービス用)
resource "aws_lb_target_group" "main" {
  name                 = "${var.service_prefix}-tg"
  port                 = 3000 # コンテナのポート
  protocol             = "HTTP"
  vpc_id               = aws_vpc.this.id
  target_type          = "ip" # ECS Fargateの場合は "ip" を指定
  deregistration_delay = 60

  health_check {
    path = "/health" # ヘルスチェックパス (アプリケーションに合わせて変更)
    port = 3000
  }

  tags = {
    Name = "${var.service_prefix}-tg"
  }
}


# 出力変数
output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.main.arn
} 