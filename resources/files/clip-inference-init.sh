#!/bin/bash

sudo apt-get -y update
sudo apt-get -y install s3cmd
cat > /root/.s3cfg <<EOF
access_key = $AWS_ACCESS_KEY_ID
secret_key = $AWS_SECRET_ACCESS_KEY
EOF
s3cmd ls
