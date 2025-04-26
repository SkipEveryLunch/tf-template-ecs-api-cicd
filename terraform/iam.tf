/**
 * ECS用IAMリソース
 */

# ECSタスク実行ロール（タスク起動時の権限）
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.service_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.service_prefix}-ecs-task-execution-role"
  }
}

# ECSタスク実行ロールにAmazonECSTaskExecutionRolePolicyをアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECSタスク実行ロールにECS Exec用のポリシーを追加
resource "aws_iam_role_policy" "ecs_exec_policy" {
  name = "${var.service_prefix}-ecs-exec-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# Secrets Managerからの読み取り権限をタスク実行ロールに追加
resource "aws_iam_policy" "secrets_manager_read" {
  name        = "${var.service_prefix}-secrets-manager-read"
  description = "Allow reading secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ],
        Effect = "Allow",
        Resource = [
          data.aws_secretsmanager_secret.db_secret.arn,
        ]
      },
      {
        Action = [
          "kms:Decrypt"
        ],
        Effect   = "Allow",
        Resource = ["*"],
        Condition = {
          StringEquals = {
            "kms:ViaService" : "secretsmanager.${var.default_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Secrets Manager読み取りポリシーをタスク実行ロールにアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_manager_read.arn
}

# ECSタスクロール（コンテナ実行時の権限）
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.service_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.service_prefix}-ecs-task-role"
  }
}

# ECSタスクロールに必要な権限を付与
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "${var.service_prefix}-ecs-task-policy"
  description = "Policy for ECS task"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# タスクポリシーをタスクロールにアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# ECSタスクロールにECS Exec用のポリシーを追加
resource "aws_iam_role_policy" "ecs_task_exec_policy" {
  name = "${var.service_prefix}-ecs-task-exec-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

# Firehose用のIAMロール
resource "aws_iam_role" "firehose" {
  name = "${var.service_prefix}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.service_prefix}-firehose-role"
  }
}

# Firehose用のIAMポリシー
resource "aws_iam_role_policy" "firehose" {
  name = "${var.service_prefix}-firehose-policy"
  role = aws_iam_role.firehose.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
      }
    ]
  })
}

# CloudWatch Logs用のIAMロール
resource "aws_iam_role" "cloudwatch" {
  name = "${var.service_prefix}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.service_prefix}-cloudwatch-role"
  }
}

# CloudWatch Logs用のIAMポリシー
resource "aws_iam_role_policy" "cloudwatch" {
  name = "${var.service_prefix}-cloudwatch-policy"
  role = aws_iam_role.cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = [aws_kinesis_firehose_delivery_stream.logs.arn]
      }
    ]
  })
}

# CodePipeline用のIAMロール
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.service_prefix}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

# CodePipeline用のIAMポリシー
resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.service_prefix}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # バケットレベル操作
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucketVersions"
        ],
        Resource = aws_s3_bucket.codepipeline_artifacts.arn
      },
      # オブジェクトレベル操作
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucketVersions",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl"
        ]
        Resource = [
          aws_s3_bucket.codepipeline_artifacts.arn,
          "${aws_s3_bucket.codepipeline_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = [
          aws_codebuild_project.build.arn,
          aws_codebuild_project.migration.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = [
          aws_codestarconnections_connection.github.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeClusters",
          "ecs:ListClusters",
          "ecs:DescribeServices",
          "ecs:ListServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:UpdateService",
          "ecs:RegisterTaskDefinition",
          "ecs:TagResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowPassEcsRoles"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.ecs_task_execution_role.arn,
          aws_iam_role.ecs_task_role.arn,
        ]
        Condition = {
          StringEquals = {
            "iam:PassedToService" : [
              "ecs.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# CodeBuild Role
resource "aws_iam_role" "codebuild_role" {
  name = "ecs-api-cicd-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "ecs-api-cicd-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.codepipeline_artifacts.arn,
          "${aws_s3_bucket.codepipeline_artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress"
        ]
        Resource = "*"
      }
    ]
  })
}
