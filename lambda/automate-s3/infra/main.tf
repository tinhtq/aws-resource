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

resource "aws_s3_bucket" "bucket" {
  bucket = "automate-s3-25-aug"
}
resource "aws_s3_bucket_acl" "acl" {
    bucket = aws_s3_bucket.bucket.id
    acl = "public-read"
  
}
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"PublicReadGetObject",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"]
    }
  ]
}
POLICY
}
resource "aws_s3_object" "object" {
  for_each = fileset("csv/", "*")
  bucket   = aws_s3_bucket.bucket.id
  key      = each.value
  source   = "csv/${each.value}"
  etag = filemd5("csv/${each.value}")
}
