resource "databricks_secret_scope" "app" {
  name = "app"
}

resource "databricks_secret" "aws_access_key_id" {
  key          = "aws_access_key_id"
  string_value = var.aws_access_key_id
  scope        = databricks_secret_scope.app.id
}

resource "databricks_secret" "aws_secret_access_key" {
  key          = "aws_secret_access_key"
  string_value = var.aws_secret_access_key
  scope        = databricks_secret_scope.app.id
}

resource "databricks_secret" "huggingface_token" {
  key          = "huggingface_token"
  string_value = var.huggingface_token
  scope        = databricks_secret_scope.app.id
}
