# Databricks notebook source
# MAGIC %pip install huggingface_hub==0.35.3

# COMMAND ----------

import os
import tempfile
from huggingface_hub import snapshot_download

def sync_hf_repo_to_s3(repo_id: str, hf_token: str, s3_target_path: str):
    """
    Downloads a complete Hugging Face repository to a temporary location on the
    Databricks driver and uploads it to a specified S3 path.

    Args:
        repo_id (str): The ID of the Hugging Face repository (e.g., "stabilityai/stable-diffusion-2-1").
        hf_token (str): The Hugging Face API token for authorization.
        s3_target_path (str): The destination S3 path (e.g., "s3://my-bucket/models/my-model").
                               The final repository files will be inside a subfolder here.
    """
    print(f"--- Starting sync for repository: {repo_id} ---")

    # Use a managed temporary directory that cleans itself up automatically
    with tempfile.TemporaryDirectory() as temp_dir:
        print(f"Created temporary directory: {temp_dir}")

        # 1. Download all files from the repository
        try:
            print(f"Downloading '{repo_id}' from Hugging Face Hub...")
            # local_dir_use_symlinks=False ensures we get actual file copies,
            # which is safer for uploading.
            snapshot_download(
                repo_id=repo_id,
                repo_type="dataset",
                local_dir=temp_dir,
                token=hf_token
                # To download specific file types, use allow_patterns
                # e.g., allow_patterns=["*.json", "*.safetensors", "*.txt"]
            )
            print("Download complete.")
        except Exception as e:
            print(f"Error downloading repository '{repo_id}': {e}")
            return

        # 2. Upload the downloaded content to S3
        # The source path for dbutils needs to be prefixed with 'file:/'
        # to indicate it's on the local driver filesystem.
        local_fs_path = f"file:{temp_dir}"

        # Ensure the destination path ends with a slash for clean copying
        if not s3_target_path.endswith('/'):
            s3_target_path += '/'

        print(f"Uploading files from '{local_fs_path}' to '{s3_target_path}'...")
        try:
            # Use dbutils.fs.cp with recurse=True to copy the entire directory
            dbutils.fs.cp(local_fs_path, s3_target_path, recurse=True)
            print("Upload to S3 complete.")
        except Exception as e:
            print(f"Error uploading to S3: {e}")
            print("Please ensure your cluster's instance profile has write permissions for the target S3 bucket.")
            return

    print(f"--- Sync for '{repo_id}' finished successfully! ---")

# COMMAND ----------

hf_repo_id = dbutils.widgets.get("dataset_id")
dataset_name = dbutils.widgets.get("dataset_name")

s3_bucket = dbutils.widgets.get("s3_bucket_name")
s3_folder_path = f"s3://{s3_bucket}/datasets/{dataset_name}"

try:
    huggingface_token = dbutils.secrets.get(scope="app", key="huggingface_token")
    print("Successfully retrieved Hugging Face token from Databricks Secrets.")
except Exception as e:
    print("Could not retrieve Hugging Face token.")
    print("Please ensure you have created a secret scope 'huggingface' with a key 'hf_token'.")
    raise e

sync_hf_repo_to_s3(
    repo_id=hf_repo_id,
    hf_token=huggingface_token,
    s3_target_path=s3_folder_path
)

# COMMAND ----------

print("\n--- Verifying files in S3 ---")
display(dbutils.fs.ls(s3_folder_path))
