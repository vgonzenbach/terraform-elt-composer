#!/bin/bash

# Must set project id with `gcloud config set project <YOUR_PROJECT>`
PROJECT_ID=$(gcloud config list --format 'value(core.project)')
echo "project_id = \"""$PROJECT_ID""\"" > terraform.auto.tfvars

terraform init

if [ "$1" = "plan" ]; then
    terraform plan 

elif [ "$1" = "apply" ]; then
    terraform apply 

else 
    echo "Choose arg 'plan' or 'apply'"
fi
