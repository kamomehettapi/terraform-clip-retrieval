data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "img2dataset_cluster" {
  cluster_name  = "img2dataset cluster"
  spark_version = "10.4.x-scala2.12"

  node_type_id            = "r5d.2xlarge"
  autotermination_minutes = 30

  kind    = "CLASSIC_PREVIEW"
  no_wait = true
  autoscale {
    min_workers = 2
    max_workers = var.img2dataset_max_node_count
  }

  aws_attributes {
    instance_profile_arn = databricks_instance_profile.instance_profile.id
  }

  init_scripts {
    workspace {
      destination = databricks_workspace_file.img2dataset_init.path
    }
  }

  cluster_log_conf {
    s3 {
      destination = "s3://${data.aws_s3_bucket.log_bucket.id}/cluster-logs/img2dataset"
      region      = var.aws_region
    }
  }

  spark_env_vars = {
    AWS_ACCESS_KEY_ID     = databricks_secret.aws_access_key_id.config_reference
    AWS_SECRET_ACCESS_KEY = databricks_secret.aws_secret_access_key.config_reference
  }
}

resource "databricks_cluster" "clip_inference_cluster" {
  cluster_name   = "clip-inference cluster"
  spark_version  = data.databricks_spark_version.latest_lts.id
  use_ml_runtime = true

  driver_node_type_id     = "m5d.large"
  node_type_id            = var.clip_inference_node_type_id
  autotermination_minutes = 30

  kind    = "CLASSIC_PREVIEW"
  no_wait = true
  autoscale {
    min_workers = 1
    max_workers = var.clip_inference_max_node_count
  }

  aws_attributes {
    availability           = "SPOT" # on-demand is expensive for P4 nodes
    first_on_demand        = 1      # request on-demand for driver node only
    zone_id                = "auto" # select any AZ in the configured region with capacity
    spot_bid_price_percent = 100

    instance_profile_arn = databricks_instance_profile.instance_profile.id
  }

  init_scripts {
    workspace {
      destination = databricks_workspace_file.clip_inference_init.path
    }
  }

  cluster_log_conf {
    s3 {
      destination = "s3://${data.aws_s3_bucket.log_bucket.id}/cluster-logs/clip-inference"
      region      = var.aws_region
    }
  }

  spark_conf = {
    # "spark.executor.cores" : var.clip_inference_cores_per_executor,
    "spark.executor.resource.gpu.amount" : var.clip_inference_gpus_per_executor,
    # "spark.task.cpus" : var.clip_inference_cores_per_executor,
    "spark.task.resource.gpu.amount" : 1,
    # "spark.cores.max" : var.clip_inference_cores_per_executor * (var.clip_inference_node_count + 1) * var.clip_inference_gpus_per_executor,
    "spark.executor.memory" : "${(var.clip_inference_memory_per_executor / 4) * 3}G",
    "spark.executor.memoryOverhead" : "${var.clip_inference_memory_per_executor / 4}G",
    "spark.task.maxFailures" : 10,
  }

  spark_env_vars = {
    AWS_ACCESS_KEY_ID     = databricks_secret.aws_access_key_id.config_reference
    AWS_SECRET_ACCESS_KEY = databricks_secret.aws_secret_access_key.config_reference
  }
}
