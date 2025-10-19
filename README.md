# clip-retrieval-workspace

Here is an attempt to recreate [clip-retrieval](https://github.com/rom1504/clip-retrieval) index creation in a reproducible way

With provided Terraform infrastructure you can

- Fetch dataset metadata
- Download all dataset images distributed
- Create `clip-retrieval` index with GPU-powered machines distributed

All work is done in end-to-end fashion.

## Prerequisites

- `jq`
- `databricks-cli`
- `aws-cli`
- S3 Bucket in AWS account where all data will be stored

## Structure

- `workspace/`: Infrastructure for Databricks workspace
- `resources/`: All resources created inside the new Databricks workspace (notebooks, compute, job definition, etc.)

## Configuration

Please edit `terraform.tfvars` and `secrets.tfvars` for both workspaces, and check variable descriptions

## Deployment

1. Authenticate with Databricks and AWS, example env vars:

``` bash
export DATABRICKS_ACCOUNT_ID="<...>"
export AWS_ACCESS_KEY_ID="<...>"
export AWS_SECRET_ACCESS_KEY="<...>"
```

2. Make sure `terraform.tfvars` AND `secrets.tfvars` are created for BOTH Terraform workspaces

3. Deploy!

``` bash
bash deploy_terraform.sh
```

## Notebooks

There are three notebooks total, to be run in order

1. `fetch-dataset.py`: Downloads the metadata for the desired LAION, and uploads to configured S3 bucket
2. `img2dataset.py`: Runs the `img2dataset` command to download all images in LAION dataset, convert to WebDataset
3. `clip-inference.py`: Runs inference step of `clip-retrieval` on created WebDataset files

These three notebooks are tied together with a Databricks job.

## Running E2E Pipeline Job

**Note:** Make sure both workspaces are deployed before running these scripts

To run E2E job from CLI:

1. Create a profile for newly created workspace in `~/.databrickscfg` with following commandline:

``` bash
bash databricks_login.sh
```

2. Run job by passing a job definition you modify (assuming profile was named `my-profile`):

```bash
bash submit_job.sh job_configs/relaion-pop-vit-l-336.json -p my-profile
```

3. Open Databricks workspace and check job run

## Job Parameters

The configuration for img2dataset and clip-inference runs may be adjust by changing job params in the `job_configs/` JSON files

List of valid job params:

### Shared

- `dataset_id`: `org_id/repo_id` identifier to download from HuggingFace 
- `dataset_name`: Folder that fetch-dataset/img2dataset files will be saved to in S3 (`s3://my-bucket/datasets/<dataset_name>/`, `s3://my-bucket/downloaded/<dataset_name>/`)
- `output_name`: Output folder of clip-retrieval index in S3 (`s3://my-bucket/output/<output_name>/`)
- `s3_bucket_name`: Job default is set automatically through Terraform, should not need changing

### img2dataset

- `img2dataset_processes_count`: Processes for img2dataset (default 16)
- `img2dataset_thread_count`: Threads for img2dataset (default 32)
- `image_size`: Pixel size for img2dataset to download images (usually, 256 or 336)
- `url_col`: In selected dataset, the column name containing image URL
- `caption_col`: In selected dataset, the column name containing image caption
- `save_additional_columns`: In selected dataset, additional column names to save in metadata (comma separated)

### clip-inference

- `clip_model`: Name of clip model. Uses [all-clip](https://github.com/data2ml/all-clip?tab=readme-ov-file#supported-models) syntax
- `write_batch_size`: Number of images per Spark job, determines the shard/total task count. Divide total dataset size by this for resulting number of tasks
