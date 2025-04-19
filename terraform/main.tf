terraform {
  required_version = "1.10.5"
  required_providers {
    aws = {
      version = "5.86.1"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.default_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Environment = var.default_tags
      Project     = var.service_prefix
      Terraform   = var.default_tags
    }
  }
}
