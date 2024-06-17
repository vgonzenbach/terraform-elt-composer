PROJECT_ID=$(gcloud config list --format 'value(core.project)')

terraform init && terraform apply -var="project_id=$PROJECT_ID"