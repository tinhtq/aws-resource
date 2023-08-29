terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}
locals {
    account_id = data.aws_caller_identity.current.account_id
}