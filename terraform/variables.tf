variable "default_region" {
  default = "ap-northeast-1"
  type    = string
}

variable "service_prefix" {
  default = "app"
  type    = string
}

variable "create_certificate" {
  description = "Whether to create an SSL/TLS certificate"
  type        = bool
  default     = true # 2回目以降はfalseにする
}

variable "default_tags" {
  default = "sel-practice"
  type    = string
}

variable "domain_name" {
  description = "The domain name for Route53 hosted zone"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  sensitive   = true
}

variable "api_subdomain_prefix" {
  description = "The prefix for the subdomain (e.g. 'api' for api.example.com)"
  type        = string
}

variable "s3_bucket_suffix" {
  description = "Suffix for S3 bucket names"
  type        = string
}

# GitHubリポジトリのID
# 形式: organization_name/repository_name
# 例: octocat/Hello-World
# 注意: GitHubのリポジトリURL（https://github.com/octocat/Hello-World）から抽出する場合は、
# organization_nameとrepository_nameの部分のみを使用してください。
variable "github_repository_id" {
  type = string
}

variable "github_target_branch" {
  description = "GitHubのターゲットブランチ名"
  type        = string
}


