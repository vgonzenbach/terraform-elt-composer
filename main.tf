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
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "composer.googleapis.com",
    "bigquery.googleapis.com"
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
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.0"
  project_id = var.project_id

  names = [var.composer_env_name]
  project_roles = [
    "${var.project_id}=>roles/composer.worker",
    "${var.project_id}=>roles/bigquery.dataViewer",
    "${var.project_id}=>roles/bigquery.jobUser"
  ]

  depends_on = [
    module.activate_google_apis
  ]
}

module "simple-composer-environment" {
  source                   = "terraform-google-modules/composer/google//modules/create_environment_v2"
  version                  = "~> 5.0"
  project_id               = var.project_id
  composer_env_name        = var.composer_env_name
  region                   = var.region
  composer_service_account = module.service_accounts.email
  network                  = var.vpc_name
  subnetwork               = var.subnet_name
  #pod_ip_allocation_range_name         = "test-subnet-pod-ip-name"
  #service_ip_allocation_range_name     = "test-subnet-service-ip-name"
  #grant_sa_agent_permission            = false
  environment_size        = "ENVIRONMENT_SIZE_SMALL"
  enable_private_endpoint = true
  use_private_environment = true

  depends_on = [
    module.activate_google_apis
  ]
}

module "bigquery" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 7.0"

  project_id = var.project_id
  dataset_id = var.dataset_id
  location   = var.bq_region


  tables = [
    {
      table_id = "curr_exchange",
      schema   = file("schemas/curr_exchange.json")
      time_partitioning = {
        type                     = "DAY",
        field                    = "rate_date"
        require_partition_filter = true
        expiration_ms            = null
      },
      clustering         = ["country"]
      range_partitioning = null
      expiration_time    = null
      labels             = null
    },
    {
      table_id           = "outlets_info"
      schema             = file("schemas/outlets_info.json")
      time_partitioning  = null
      clustering         = null
      range_partitioning = null
      expiration_time    = null
      labels             = null

    },
    {
      table_id = "output_table"
      schema   = file("schemas/output_table.json")
      time_partitioning = {
        type                     = "DAY"
        field                    = "sales_date"
        require_partition_filter = true
        expiration_ms            = null
      }
      clustering         = null
      range_partitioning = null
      expiration_time    = null
      labels             = null
    },
    {
      table_id           = "products_info"
      schema             = file("schemas/products_info.json")
      time_partitioning  = null
      clustering         = null
      range_partitioning = null
      expiration_time    = null
      labels             = null
    },
    {
      table_id = "sales_daily"
      schema   = file("schemas/sales_daily.json")
      time_partitioning = {
        type                     = "DAY"
        field                    = "sales_date"
        require_partition_filter = true
        expiration_ms            = null
      }
      clustering         = ["country"]
      range_partitioning = null
      expiration_time    = null
      labels             = null
    }
  ]

  depends_on = [
    module.activate_google_apis
  ]
}

