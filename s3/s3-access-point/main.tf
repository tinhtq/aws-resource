# Step 1: Create an S3 bucket for storing the customer records
resource "aws_s3_bucket" "customer_records" {
  bucket = "${data.aws_caller_identity.current.account_id}-customer-records-bucket"  # Ensure the name is globally unique
}

# Step 2: Create an IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Step 3: Attach policy for Lambda to access the S3 bucket
resource "aws_iam_policy" "lambda_s3_access_policy" {
  name = "lambda_s3_access_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.customer_records.arn}/*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_object_lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonS3ObjectLambdaExecutionRolePolicy"
}

# Step 4: Create the Lambda function (assuming the Lambda ZIP package is uploaded)
resource "aws_lambda_function" "remove_pii" {
  function_name = "removePii"
  filename      = "lambda.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler = "main.lambda_handler"  
  runtime = "python3.10"  # Adjust as per your runtime
  role    = aws_iam_role.lambda_execution_role.arn
  timeout = 30
  environment {
    variables = {
        "BUCKET_NAME" = aws_s3_bucket.customer_records.id
    }
  }
}

# Step 5: Create an S3 Object Lambda Access Point
resource "aws_s3_access_point" "ap" {
  bucket = aws_s3_bucket.customer_records.id
  name   = "customer-records-ap"

}

resource "aws_s3_object" "name" {
  bucket = aws_s3_bucket.customer_records.id
  key = "data.json"
  source = "./data.json"
}

resource "aws_s3control_object_lambda_access_point" "example" {
  name = "customer-records-obj-ap"

  configuration {
    supporting_access_point = aws_s3_access_point.ap.arn

    transformation_configuration {
      actions = ["GetObject"]

      content_transformation {
        aws_lambda {
          function_arn = aws_lambda_function.remove_pii.arn
        }
      } 
    }
  }
}

