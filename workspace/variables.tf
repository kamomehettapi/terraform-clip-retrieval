variable "aws_region" {
  default     = "us-east-2"
  type        = string
  description = "AWS region to deploy to"
}

variable "databricks_account_id" {
  type        = string
  sensitive   = true
  description = "Databricks account ID"
}

variable "databricks_user_id" {
  type        = number
  sensitive   = true
  description = "Numeral user ID of the user you use to login to Databricks, so they can be added as admin to new workspace"
}

# variable "databricks_client_id" {
#   type        = string
#   sensitive   = true
#   description = "Client ID to authenticate Databricks provider"
# }

# variable "databricks_client_secret" {
#   type        = string
#   sensitive   = true
#   description = "Client secret to authenticate Databricks provider"
# }

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Optional tags to add to created resources"
}

variable "cidr_block" {
  description = "IP range for AWS VPC"
  type        = string
  default     = "10.4.0.0/16"
}

variable "prefix" {
  type        = string
  description = "Prefix for use in the generated names"
}
