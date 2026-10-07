terraform {
  required_version = ">= 1.11.0, < 2.0.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = { Project = var.resource_prefix, Environment = "dev", ManagedBy = "terraform", Owner = var.owner, CostCenter = var.cost_center }
  }
}
