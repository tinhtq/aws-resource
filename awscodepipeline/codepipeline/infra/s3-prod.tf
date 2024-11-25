
resource "aws_s3_bucket" "bucket_prod" {
  force_destroy = true
  bucket = "codepipeline-${local.account_id}-prod"
}
resource "aws_s3_bucket_acl" "acl" {
    bucket = aws_s3_bucket.bucket_prod.id
    acl    = "public-read"
    depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership_prod]
}

resource "aws_s3_bucket_public_access_block" "access_block_prod" {
  bucket = aws_s3_bucket.bucket_prod.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership_prod" {
  bucket = aws_s3_bucket.bucket_prod.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.access_block_prod]
}

resource "aws_s3_bucket_policy" "bucket_policy_prod" {
  bucket = aws_s3_bucket.bucket_prod.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account_prod.json
  depends_on = [ aws_s3_bucket_public_access_block.access_block_prod ]
}

data "aws_iam_policy_document" "allow_access_from_another_account_prod" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.bucket_prod.arn,
      "${aws_s3_bucket.bucket_prod.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_versioning" "versioning_prod" {
  bucket = aws_s3_bucket.bucket_prod.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "example_web" {
  bucket = aws_s3_bucket.bucket_prod.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
