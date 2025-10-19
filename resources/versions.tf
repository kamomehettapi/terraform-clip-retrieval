terraform {
  cloud {
    organization = "example-org-68b67e"
    workspaces {
      name = "tf-clip-retrieval"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.15.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "1.91.0"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = "0.70.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
  }
}

provider "tfe" {}

provider "aws" {
  region = var.aws_region
}

provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = data.tfe_outputs.workspace.values.databricks_sp_id
  client_secret = data.tfe_outputs.workspace.values.databricks_sp_secret
  auth_type     = "oauth-m2m"
}

provider "databricks" {
  host          = data.tfe_outputs.workspace.values.databricks_host
  account_id    = var.databricks_account_id
  client_id     = data.tfe_outputs.workspace.values.databricks_sp_id
  client_secret = data.tfe_outputs.workspace.values.databricks_sp_secret
  auth_type     = "oauth-m2m"
}

provider "time" {}
