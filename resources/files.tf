data "databricks_service_principal" "sp" {
  provider       = databricks.mws
  application_id = data.tfe_outputs.workspace.values.databricks_sp_id
}

locals {
  notebook_path = "${data.databricks_service_principal.sp.home}/Terraform"
}

resource "databricks_notebook" "fetch_dataset" {
  source = "${path.module}/files/fetch-dataset.py"
  path   = "${local.notebook_path}/fetch-dataset"
}

resource "databricks_notebook" "img2dataset" {
  source = "${path.module}/files/img2dataset.py"
  path   = "${local.notebook_path}/img2dataset"
}

resource "databricks_notebook" "clip_inference" {
  source = "${path.module}/files/clip-inference.py"
  path   = "${local.notebook_path}/clip-inference"
}

resource "databricks_workspace_file" "img2dataset_init" {
  source = "${path.module}/files/img2dataset-init.sh"
  path   = "${local.notebook_path}/img2dataset-init.sh"
}

resource "databricks_workspace_file" "clip_inference_init" {
  source = "${path.module}/files/clip-inference-init.sh"
  path   = "${local.notebook_path}/clip-inference-init.sh"
}
