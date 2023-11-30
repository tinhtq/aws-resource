module "dynamodb" {
  source = "./dynamodb"
  region = var.region
}
module "ec2" {
  source = "./ec2"
  region = var.region
}
module "efs" {
  source = "./efs"
  region = var.region
}
module "kms" {
  source = "./kms"
  region = var.region
}
module "rds" {
  source = "./rds"
  region = var.region
}
module "s3" {
  source = "./s3"
  region = var.region
}

variable "region" {
  default = "us-west-2"
}
