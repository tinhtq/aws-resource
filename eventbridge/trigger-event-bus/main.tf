resource "aws_cloudwatch_event_bus" "trigger" {
  name = "trigger-event-bridge"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda/main.py" 
  output_path = "./lambda/lambda.zip"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "my_lambda" {
  function_name = "event-bridge-integration"
  
  # Use the zip file created by archive_file
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler"  # Ensure this matches the function in main.py
  runtime          = "python3.10"            # Or another Python runtime version
  
  memory_size      = 128
  timeout          = 10
}
