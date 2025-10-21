#!/usr/bin/env bash

set -x

# Get the job config file path from first argument
JOB_CONFIG="$1"
shift

# Get the e2e_job_id from terraform output
pushd ./resources
JOB_ID=$(terraform output -raw e2e_job_id)
popd

# Check if job_id was retrieved successfully
if [ -z "$JOB_ID" ]; then
    echo "Error: Failed to get e2e_job_id from terraform output"
    exit 1
fi

# Create temporary file with updated job_id
TEMP_CONFIG=$(mktemp)
jq --arg job_id "$JOB_ID" '.job_id = ($job_id | tonumber)' "$JOB_CONFIG" > "$TEMP_CONFIG"

# Submit the job with databricks CLI
databricks jobs run-now --no-wait --json @"$TEMP_CONFIG" "$@"

# Clean up temporary file
rm "$TEMP_CONFIG"
