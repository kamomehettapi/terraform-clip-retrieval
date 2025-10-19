aws_region         = "us-east-2"
s3_bucket_name     = "my-bucket"
s3_log_bucket_name = "my-bucket"
hcp_organization   = "example-org-68b67e"

img2dataset_max_node_count = 10

clip_inference_max_node_count      = 1
clip_inference_node_type_id        = "p4d.24xlarge"
clip_inference_gpus_per_executor   = 8
clip_inference_memory_per_executor = 24
