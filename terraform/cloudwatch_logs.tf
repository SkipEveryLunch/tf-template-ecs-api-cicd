# CloudWatch LogsからFirehoseへのサブスクリプションフィルター
resource "aws_cloudwatch_log_subscription_filter" "logs" {
  name            = "${var.service_prefix}-logs-filter"
  log_group_name  = aws_cloudwatch_log_group.ecs_logs.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.logs.arn
  role_arn        = aws_iam_role.cloudwatch.arn
} 