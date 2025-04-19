/**
 * ECSサービス関連リソース
 */

# ECSサービス
resource "aws_ecs_service" "main" {
  name                               = "${var.service_prefix}-app-service"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  scheduling_strategy                = "REPLICA"
  enable_execute_command             = true # ECS Execを有効化

  # ヘルスチェックの猶予期間（秒）
  health_check_grace_period_seconds = 60

  # ネットワーク設定
  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_c.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  # ロードバランサーとの連携
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "app"
    container_port   = 3000
  }

  # デプロイ設定
  deployment_controller {
    type = "ECS"
  }

  # デプロイに失敗した場合、前回の正常なデプロイまでロールバックする
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    # ここで指定した項目については、terraform applyで上書きをしないようにする
    ignore_changes = [
      task_definition, # CI/CDパイプラインで更新される可能性があるため
      desired_count,   # Auto Scalingで更新される可能性があるため
    ]
  }

  depends_on = [aws_lb_listener.https]

  tags = {
    Name = "${var.service_prefix}-app-service"
  }
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "main" {
  max_capacity       = 1 # 一旦最小構成とする
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU使用率に基づくAuto Scalingポリシー
resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.service_prefix}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# メモリ使用率に基づくAuto Scalingポリシー
resource "aws_appautoscaling_policy" "memory" {
  name               = "${var.service_prefix}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
} 