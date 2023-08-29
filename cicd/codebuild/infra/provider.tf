terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.14.0"
    }
  }
}
