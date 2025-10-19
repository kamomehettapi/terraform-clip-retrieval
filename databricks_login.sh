#!/bin/bash

# Get databricks host and account id from terraform outputs
pushd ./resources
DATABRICKS_HOST=$(terraform output -raw databricks_host)
DATABRICKS_ACCOUNT_ID=$(terraform output -raw databricks_account_id)
popd

# Check if outputs were retrieved successfully
if [ -z "$DATABRICKS_HOST" ] || [ -z "$DATABRICKS_ACCOUNT_ID" ]; then
    echo "Error: Failed to get databricks_host or databricks_account_id from terraform output"
    exit 1
fi

# Login to databricks with terraform outputs
databricks auth login --host "$DATABRICKS_HOST" --account-id "$DATABRICKS_ACCOUNT_ID" "$@"
