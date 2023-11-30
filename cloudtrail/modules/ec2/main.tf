terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}
variable "resources" {
  default = "ec2"
}
provider "aws" {
  region = var.region
}
