# Databricks notebook source
# MAGIC %pip install s3fs git+https://github.com/rom1504/img2dataset
# MAGIC %restart_python

# COMMAND ----------

hf_repo_id = dbutils.widgets.get("dataset_id")
images_name = dbutils.widgets.get("images_name")
s3_bucket_name = dbutils.widgets.get("s3_bucket_name")
output_dir = f"s3://{s3_bucket_name}/images/{images_name}"
url_list = f"s3://{s3_bucket_name}/datasets/{hf_repo_id}/"

image_size = int(dbutils.widgets.get("image_size"))
url_col = dbutils.widgets.get("url_col")
caption_col = dbutils.widgets.get("caption_col")
processes_count = dbutils.widgets.get("img2dataset_processes_count")
thread_count = dbutils.widgets.get("img2dataset_thread_count")
save_additional_columns = dbutils.widgets.get("save_additional_columns").split(",")

# COMMAND ----------

from img2dataset import download

download(
        processes_count=processes_count,
        thread_count=thread_count,
        url_list=url_list,
        image_size=image_size,
        resize_only_if_bigger=True,
        resize_mode="keep_ratio",
        skip_reencode=True,
        output_folder=output_dir,
        output_format="webdataset",
        input_format="parquet",
        url_col=url_col,
        caption_col=caption_col,
        enable_wandb=False,
        number_sample_per_shard=10000,
        distributor="pyspark",
        oom_shard_count=6,
        incremental_mode="incremental",
        user_agent_token=None,
        extract_exif=True,
        save_additional_columns=save_additional_columns,
        ignore_ssl_certificate=True
)
