#!/bin/bash

set -e

pushd resources/
S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)
popd

if [ -z "$S3_BUCKET_NAME" ]; then
    echo "Error: Could not retrieve 's3_bucket_name' from Terraform." >&2
    exit 1
fi

FOLDER_NAME=$1
S3_OUTPUT_PREFIX="output/"
OUTPUT_FOLDER="output/"

if [ -n "$FOLDER_NAME" ]; then
  mkdir -p "${OUTPUT_FOLDER}"
  S3_SOURCE="s3://${S3_BUCKET_NAME}/${S3_OUTPUT_PREFIX}${FOLDER_NAME}/"
  LOCAL_DEST="./${OUTPUT_FOLDER}/${FOLDER_NAME}"
  echo "Downloading from $S3_SOURCE to $LOCAL_DEST..."
  aws s3 cp --recursive "$S3_SOURCE" "$LOCAL_DEST"
else
  aws s3api list-objects-v2 --bucket "$S3_BUCKET_NAME" --prefix "$S3_OUTPUT_PREFIX" --delimiter "/" | \
  jq -r '.CommonPrefixes[].Prefix' | sed "s#^$S3_OUTPUT_PREFIX##; s#/\$##"
fi
