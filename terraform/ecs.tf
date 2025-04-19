/**
 * ECSクラスターとタスク定義関連リソース
 */

# ECSクラスターの作成
resource "aws_ecs_cluster" "this" {
  name = "${var.service_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.service_prefix}-cluster"
  }
}

# ECSタスク定義
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.service_prefix}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.main.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        },
        {
          containerPort = 22
          hostPort      = 22
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "DATABASE_URL"
          value = local.database_url_for_prisma
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.service_prefix}"
          "awslogs-region"        = var.default_region
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

  tags = {
    Name = "${var.service_prefix}-app-task"
  }
}

# CloudWatch Logsグループ
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.service_prefix}"
  retention_in_days = 30

  tags = {
    Name = "${var.service_prefix}-logs"
  }
}
