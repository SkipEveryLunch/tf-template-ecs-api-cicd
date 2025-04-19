resource "aws_s3_bucket" "logs" {
  # バケット名は全世界で一意である必要があるので、ユニークな値をsuffixとする（自動生成推奨）
  # 小文字のalphanumericな文字とハイフンのみ許容される
  bucket        = "${var.service_prefix}-ecs-logs-${var.s3_bucket_suffix}"
  force_destroy = true

  tags = {
    Name = "${var.service_prefix}-ecs-logs-${var.s3_bucket_suffix}"
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_kinesis_firehose_delivery_stream" "logs" {
  name        = "${var.service_prefix}-logs"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = aws_s3_bucket.logs.arn
    prefix             = "ecs-logs/"
    buffering_size     = 5
    buffering_interval = 300
    compression_format = "GZIP"
  }
} 