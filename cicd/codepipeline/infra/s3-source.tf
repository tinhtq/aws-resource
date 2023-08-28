
resource "aws_s3_bucket" "bucket_source" {
  bucket = "codepipeline-601619162398-source"
}
resource "aws_s3_bucket_acl" "acl_source" {
  bucket     = aws_s3_bucket.bucket_source.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.acl_ownership_source]
}



resource "aws_s3_bucket_public_access_block" "access_block_source" {
  bucket = aws_s3_bucket.bucket_source.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "acl_ownership_source" {
  bucket = aws_s3_bucket.bucket_source.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.access_block_source]
}

resource "aws_s3_bucket_policy" "bucket_policy_source" {
  bucket     = aws_s3_bucket.bucket_source.id
  policy     = data.aws_iam_policy_document.allow_access_from_another_account_source.json
  depends_on = [aws_s3_bucket_public_access_block.access_block_source]
}

data "aws_iam_policy_document" "allow_access_from_another_account_source" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.bucket_source.arn,
      "${aws_s3_bucket.bucket_source.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_versioning" "versioning_source" {
  bucket = aws_s3_bucket.bucket_source.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "object" {
  for_each = fileset("source/", "*")
  bucket   = aws_s3_bucket.bucket_source.id
  key      = each.value
  source   = "source/${each.value}"
  etag     = filemd5("source/${each.value}")
}

