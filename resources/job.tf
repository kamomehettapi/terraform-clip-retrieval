resource "databricks_job" "clip_retrieval_e2e" {
  name        = "clip-retrieval E2E"
  description = "Fetches dataset metadata, downloads full dataset, runs clip inference on dataset"

  #
  # Shared parameters
  #

  # S3 bucket that notebooks will access
  parameter {
    name    = "s3_bucket_name"
    default = data.aws_s3_bucket.external.id
  }

  #
  # fetch-dataset parameters
  #

  # `org_id/repo_id` pair of repo to download from HuggingFace (`s3://my-bucket/datasets/<dataset_id>`)
  parameter {
    name    = "dataset_id"
    default = "laion/relaion-pop"
  }

  #
  # img2dataset parameters
  #

  # Output folder of img2dataset files in S3 (`s3://my-bucket/images/<images_name>/`)
  parameter {
    name    = "images_name"
    default = "relaion-pop-336"
  }

  # Processes for img2dataset
  parameter {
    name    = "img2dataset_processes_count"
    default = "16"
  }

  # Threads for img2dataset
  parameter {
    name    = "img2dataset_thread_count"
    default = "32"
  }

  # Pixel size for img2dataset to download images (usually, 224 or 336)
  parameter {
    name    = "image_size"
    default = "336"
  }

  parameter {
    name    = "url_col"
    default = "url"
  }

  parameter {
    name    = "caption_col"
    default = "cogvlm_caption"
  }

  parameter {
    name    = "save_additional_columns"
    default = "llava_caption,nsfw_prediction,alt_txt,alt_txt_similarity"
  }

  #
  # clip-inference parameters
  #

  parameter {
    name    = "clip_model"
    default = "ViT-L/14@336px"
  }

  parameter {
    name    = "write_batch_size"
    default = "100000"
  }

  # Output folder of clip-retrieval index in S3 (`s3://my-bucket/output/<output_name>/`)
  parameter {
    name    = "output_name"
    default = "relaion-pop-vit-l-336"
  }

  task {
    task_key = "fetch-dataset"

    existing_cluster_id = databricks_cluster.img2dataset_cluster.id

    notebook_task {
      notebook_path = databricks_notebook.fetch_dataset.path
    }
  }

  task {
    task_key = "img2dataset"

    depends_on {
      task_key = "fetch-dataset"
    }

    existing_cluster_id = databricks_cluster.img2dataset_cluster.id

    notebook_task {
      notebook_path = databricks_notebook.img2dataset.path
    }
  }

  task {
    task_key = "clip-inference"

    depends_on {
      task_key = "img2dataset"
    }

    existing_cluster_id = databricks_cluster.clip_inference_cluster.id

    notebook_task {
      notebook_path = databricks_notebook.clip_inference.path
    }
  }
}
