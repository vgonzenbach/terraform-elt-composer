terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.33"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "activate_google_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  project_id                  = var.project_id
  enable_apis                 = true
  disable_services_on_destroy = false

  activate_apis = [
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "composer.googleapis.com"
  ]
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.1"

  project_id   = var.project_id
  network_name = var.vpc_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = var.subnet_name
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
    }
  ]
  depends_on = [
    module.activate_google_apis
  ]
}


module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.0"
  project_id    = var.project_id

  names         = [var.composer_env_name]
  project_roles = [
    "${var.project_id}=>roles/composer.worker"
  ]

  depends_on = [
    module.activate_google_apis
  ]
}

module "simple-composer-environment" {
  source                               = "terraform-google-modules/composer/google//modules/create_environment_v2"
  version                              = "~> 5.0"
  project_id                           = var.project_id
  composer_env_name                    = var.composer_env_name
  region                               = var.region
  composer_service_account             = module.service_accounts.email
  network                              = var.vpc_name
  subnetwork                           = var.subnet_name
  #pod_ip_allocation_range_name         = "test-subnet-pod-ip-name"
  #service_ip_allocation_range_name     = "test-subnet-service-ip-name"
  #grant_sa_agent_permission            = false
  environment_size                     = "ENVIRONMENT_SIZE_SMALL"
  enable_private_endpoint              = true
  use_private_environment              = true

  depends_on = [
    module.activate_google_apis
  ]
}

