resource "aws_kms_key" "custom_key" {
  description             = "Key for AWS Connect"
  enable_key_rotation = true
}

resource "aws_kms_alias" "custom_key_alias" {
  name          = "alias/aws-connect"
  target_key_id = aws_kms_key.custom_key.key_id
}

resource "aws_kms_key_policy" "custom_key_policy" {
  key_id = aws_kms_key.custom_key.id
  policy = jsonencode({
    Id = "example"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
    ]
    Version = "2012-10-17"
  })
}

