#!/usr/bin/env bash

set -e

pushd workspace/
terraform apply -var-file=secrets.tfvars -auto-approve
popd

pushd resources/
terraform apply -var-file=secrets.tfvars -auto-approve
popd
