#!/bin/sh

# Adds the AWS key.
eval "$(ssh-agent -s)"
ssh-add /project/aws_dcos_cluster_key

# Puts the AWS basic config available to the scripts.
. /project/aws-basic-config.properties
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION


# Exexutes the terraform script.
terraform init
terraform plan -out=create-dcos-cluster.out
#terraform apply create-dcos-cluster.out
