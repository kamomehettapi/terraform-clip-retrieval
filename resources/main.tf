data "tfe_outputs" "workspace" {
  organization = var.hcp_organization
  workspace    = var.hcp_workspace_name
}

data "aws_s3_bucket" "external" {
  bucket = var.s3_bucket_name
}
