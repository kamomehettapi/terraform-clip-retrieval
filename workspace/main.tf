module "aws-workspace-basic" {
  source                = "./modules/aws-workspace-basic"
  databricks_account_id = var.databricks_account_id
  region                = var.aws_region
  tags                  = var.tags
  prefix                = var.prefix
  cidr_block            = var.cidr_block
}

resource "databricks_service_principal" "sp" {
  display_name         = "${var.prefix}-admin"
  allow_cluster_create = true
  workspace_access     = true
}

resource "databricks_service_principal_secret" "sp" {
  service_principal_id = databricks_service_principal.sp.id
}

resource "databricks_service_principal_role" "sp_account_admin" {
  service_principal_id = databricks_service_principal.sp.id
  role                 = "account_admin"
}

data "databricks_user" "me" {
  user_id = var.databricks_user_id
}

# Add access to workspace
resource "databricks_mws_permission_assignment" "add_user" {
  workspace_id = module.aws-workspace-basic.workspace_id
  principal_id = data.databricks_user.me.id
  permissions  = ["ADMIN"]
}

# Add access to workspace
resource "databricks_mws_permission_assignment" "add_sp" {
  workspace_id = module.aws-workspace-basic.workspace_id
  principal_id = databricks_service_principal.sp.id
  permissions  = ["ADMIN"]
}
