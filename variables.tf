variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-b"
}
variable "vpc_name" {
  type    = string
  default = "elt-vpc"
}

variable "subnet_name" {
  type    = string
  default = "elt-subnet"
}

variable "composer_env_name" {
  type    = string
  default = "elt-composer-env"
}

variable "dataset_id" {
  type    = string
  default = "retail_sales"
}

variable "bq_region" {
  type    = string
  default = "EU"
}