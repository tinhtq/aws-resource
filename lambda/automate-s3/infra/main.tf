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
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
  
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.example.arn,
      "${aws_s3_bucket.example.arn}/*",
    ]
  }

}
resource "aws_s3_object" "object" {
  for_each = fileset("csv/", "*")
  bucket   = aws_s3_bucket.bucket.id
  key      = each.value
  source   = "csv/${each.value}"
  etag = filemd5("csv/${each.value}")
}
