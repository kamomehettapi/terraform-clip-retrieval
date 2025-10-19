#!/usr/bin/env bash

set -e

pushd resources/
terraform destroy -var-file=secrets.tfvars -auto-approve
popd

pushd workspace/
terraform destroy -var-file=secrets.tfvars -auto-approve
popd
