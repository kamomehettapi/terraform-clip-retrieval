output "databricks_host" {
  value       = data.tfe_outputs.workspace.values.databricks_host
  sensitive   = true
  description = "Databricks host URL of created workspace"
}

output "databricks_account_id" {
  value       = var.databricks_account_id
  sensitive   = true
  description = "Databricks account ID"
}

output "e2e_job_id" {
  value       = databricks_job.clip_retrieval_e2e.id
  description = "ID of created Databricks E2E job"
}
