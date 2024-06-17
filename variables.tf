variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "vpc_name" {
  type    = string
  default = "elt-vpc"
}

variable "subnet_name" {
  type    = string
  default = "elt-subnet"
}