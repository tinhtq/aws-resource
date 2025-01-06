provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
variable "region" {
  description = "The AWS region to deploy the resources."
  default = "us-east-1"
}

variable "access_key" {
  description = "The AWS access key."
  default = ""
}

variable "secret_key" {
  description = "The AWS secret key."
  default = ""
}