output "databricks_host" {
  value       = module.aws-workspace-basic.databricks_host
  description = "Databricks host URL of created workspace"
}

output "databricks_sp_id" {
  value       = databricks_service_principal.sp.application_id
  description = "Databricks ID of created service principal"
}

output "databricks_sp_secret" {
  value       = databricks_service_principal_secret.sp.secret
  sensitive   = true
  description = "Databricks secret of created service principal"
}

output "aws_cross_account_role_name" {
  value       = module.aws-workspace-basic.aws_cross_account_role_name
  description = "Name of AWS IAM role attached to Databricks"
}
