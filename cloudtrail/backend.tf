terraform {
  backend "s3" {
    bucket = "terraform-backend-tinhtq"
    key    = "cloudtrail/terraform.tfstate"
    region = "us-west-2"
  }
}
