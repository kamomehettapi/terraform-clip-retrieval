# Databricks notebook source
# MAGIC %pip install s3fs braceexpand git+https://github.com/kamomehettapi/clip-retrieval@km-test

# COMMAND ----------

# MAGIC %sh s3cmd ls

# COMMAND ----------

# MAGIC %sh /databricks/spark/scripts/gpu/get_gpus_resources.sh

# COMMAND ----------

import re

def generate_s3_brace_expansion(s3_directory_path: str, ext: str) -> str:
    """
    Lists files in an S3 directory, finds the min and max numerical parts of the
    filenames, and generates a bash brace expansion string.

    Args:
        s3_directory_path: The path to the S3 directory (e.g., "s3://my/s3/directory/").

    Returns:
        A brace expansion string (e.g., "s3://my/s3/directory/{000000..001000}.tar").
        Returns None if no matching files are found.
    """
    try:
        # 1. List all files in the directory using dbutils
        files = dbutils.fs.ls(s3_directory_path)
        file_paths = [f.path for f in files]
    except Exception as e:
        print(f"Error listing files from '{s3_directory_path}'. Make sure the path is correct and accessible.")
        print(f"Details: {e}")
        return None

    # Regex to capture three parts:
    # 1. The prefix (everything up to the last slash and the numbers)
    # 2. The numerical part (one or more digits)
    # 3. The suffix (the file extension, e.g., '.tar')
    # Example: "s3://my/dir/000001.tar" -> ("s3://my/dir/", "000001", ".tar")
    pattern = re.compile(r"^(.*\/)(\d+)(\..*)$")

    numbers = []
    prefix = None
    suffix = None
    padding_width = 0

    for path in file_paths:
        match = pattern.match(path)
        if not match:
            # Skip any files or subdirectories that don't match the expected pattern
            continue

        # On the first valid match, store the structure of the filename
        if prefix is None:
            prefix = match.group(1)
            suffix = match.group(3)
            # The padding is determined by the length of the first number string found
            padding_width = len(match.group(2))
            if suffix != ext:
                continue

        # 2. Extract and store the numerical part as an integer
        numbers.append(int(match.group(2)))

    # 3. Check if we found any matching files
    if not numbers:
        print(f"No files matching the pattern '.../12345.ext' were found in '{s3_directory_path}'.")
        return None

    # 4. Find the minimum and maximum values
    min_val = min(numbers)
    max_val = max(numbers)

    # 5. Format the min and max values back into strings with the correct zero-padding
    # The f-string format {:0{width}d} dynamically sets the padding width
    min_str = f"{min_val:0{padding_width}d}"
    max_str = f"{max_val:0{padding_width}d}"

    # 6. Construct the final brace expansion string
    # The double curly braces {{ and }} are used to create literal braces in an f-string
    brace_expand_string = f"{prefix}{{{min_str}..{max_str}}}.{ext}"

    return brace_expand_string

# COMMAND ----------

import os
import shutil

cache_dir = "/tmp/cache"
shutil.rmtree(cache_dir, ignore_errors=True)
os.makedirs(cache_dir, exist_ok=True)

def calc_samples_in_tar(path: str):
    urls = f"pipe:s3cmd get --quiet {path} -",
    dataset = wds.WebDataset(urls, cache_dir=cache_dir, cache_size=10**10)
    count = 0
    for _ in dataset:
        count += 1
    return count

# COMMAND ----------

import braceexpand
import webdataset as wds
import itertools

dataset_name = dbutils.widgets.get("dataset_name")
output_name = dbutils.widgets.get("output_name")
s3_bucket_name = dbutils.widgets.get("s3_bucket_name")

s3_path = f"s3://{s3_bucket_name}/images/{dataset_name}/"
input_dataset = generate_s3_brace_expansion(s3_path, "tar")
if input_dataset is None:
    raise Exception(f"Could not determine input dataset! S3 path: {s3_path}")

print(f"Input dataset: {input_dataset}")

output_folder = f"s3://{s3_bucket_name}/output/{output_name}"

# COMMAND ----------

url_count = 5

total = 0
all_datasets = braceexpand.braceexpand(input_dataset)

for url in itertools.islice(all_datasets, url_count):
    total += calc_samples_in_tar(url)

wds_number_file_per_input_file = int(total / url_count)
print(f"Estimated samples per tar: {wds_number_file_per_input_file}")

shutil.rmtree(cache_dir, ignore_errors=True)

# COMMAND ----------

write_batch_size = int(dbutils.widgets.get("write_batch_size"))
clip_model = dbutils.widgets.get("clip_model")

# COMMAND ----------

from clip_retrieval import clip_inference

clip_inference(
    input_dataset=f"pipe:s3cmd get --quiet {input_dataset} -",
    output_folder=output_folder,
    input_format="webdataset",
    enable_metadata=True,
    write_batch_size=write_batch_size,
    wds_number_file_per_input_file=wds_number_file_per_input_file,
    num_prepro_workers=8,
    batch_size=512,
    cache_path=None,
    enable_wandb=False,
    distribution_strategy="pyspark",
    clip_model=clip_model
)
