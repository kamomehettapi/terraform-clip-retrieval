# versions.tf
terraform {
  cloud {
    organization = "example-org-68b67e"
    workspaces {
      name = "tf-clip-retrieval-workspace"
    }
  }

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.13.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "databricks" {
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  # client_id     = var.databricks_client_id
  # client_secret = var.databricks_client_secret
  auth_type = "oauth-m2m"
}
