
# Create an SQS queue
resource "aws_sqs_queue" "my_queue" {
  name                        = "my-sqs-queue"
  visibility_timeout_seconds  = 30
  message_retention_seconds   = 86400
}

# Create a DynamoDB table
resource "aws_dynamodb_table" "my_table" {
  name           = "MyTable"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  billing_mode = "PAY_PER_REQUEST"
}

# Create an IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sqs_dynamodb_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Create a Lambda function
resource "aws_lambda_function" "my_lambda" {
  function_name    = "SQSLambdaConsumer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.handler"
  runtime          = "python3.10"
  timeout          = 30

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.my_table.name
    }
  }

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# Create an event source mapping between SQS and Lambda
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn  = aws_sqs_queue.my_queue.arn
  function_name     = aws_lambda_function.my_lambda.arn
  batch_size        = 10  # Adjust based on your requirements

  function_response_types = [
    "ReportBatchItemFailures"
  ]
}

output "sqs_queue_url" {
  value = aws_sqs_queue.my_queue.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.my_table.name
}
