variable "aws_region" {
  type        = string
  description = "AWS region to deploy to. Please choose same region as deployed Databricks workspace"
}

variable "aws_access_key_id" {
  type        = string
  sensitive   = true
  description = "AWS access key ID to pass into compute instances"
}

variable "aws_secret_access_key" {
  type        = string
  sensitive   = true
  description = "AWS secret access key to pass into compute instances"
}

variable "hcp_organization" {
  type        = string
  description = "HCP organization used to deploy clip-retrieval-workspace previously"
}

variable "hcp_workspace-name" {
  type        = string
  description = "HCP workspace used to deploy clip-retrieval-workspace previously"
  default     = "tf-clip-retrieval-workspace"
}

variable "databricks_account_id" {
  type        = string
  sensitive   = true
  description = "Databricks account ID"
}

variable "huggingface_token" {
  type        = string
  sensitive   = true
  description = "HuggingFace token for downloading LAION datasets"
}

variable "s3_bucket_name" {
  description = "Main bucket to store LAION metadata, datasets and output models"
  type        = string
  sensitive   = true
}

variable "s3_log_bucket_name" {
  description = "Secondary bucket to store Databricks cluster logs, can be same as s3_bucket_name"
  type        = string
  sensitive   = true
}

variable "img2dataset_max_node_count" {
  description = "Max number of worker nodes to provision for img2dataset cluster (autoscales from 2 nodes)"
  type        = number
  default     = 10
}

variable "clip_inference_max_node_count" {
  description = "Max number of worker nodes to provision for clip-inference cluster (autoscales from 1 node)"
  type        = number
  default     = 2
}

variable "clip_inference_node_type_id" {
  description = "Type of AWS node to provision for clip-inference cluster"
  type        = string
  default     = "g5.4xlarge"
}

# variable "clip_inference_cores_per_executor" {
#   description = <<EOS
# Number of CPU cores per node executor, please change according to chosen node-type.
# EOS
#   type        = number
#   default     = 16
# }

variable "clip_inference_gpus_per_executor" {
  description = <<EOS
Number of GPUs per node executor, please change according to chosen node-type.
Since assumption is each task gets 1 GPU, set to total GPU number for entire node.
EOS
  type        = number
  default     = 1
}

variable "clip_inference_memory_per_executor" {
  description = <<EOS
Amount of memory per node executor, please change according to chosen node-type.
25% of memory will be given to memory overhead.
EOS
  type        = number
  default     = 48
}
