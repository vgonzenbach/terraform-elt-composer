terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.85.0"
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
    "servicenetworking.googleapis.com"
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

