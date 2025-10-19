data "tfe_outputs" "workspace" {
  organization = "example-org-68b67e"
  workspace    = "tf-clip-retrieval-workspace"
}

data "aws_s3_bucket" "external" {
  bucket = var.s3_bucket_name
}
