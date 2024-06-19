#!/bin/bash

## set up the environment variable
# export TERRAFORM_SA=<YOUR_TERRAFORM_SA>

gcloud auth application-default login --impersonate-service-account="$TERRAFORM_SA"