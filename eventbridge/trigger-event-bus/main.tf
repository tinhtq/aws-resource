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


resource "aws_iam_policy" "trigger_event_bus_policy" {
  name = "trigger-event-bus"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.trigger_event_bus_policy.arn
}


resource "aws_lambda_function" "trigger-event-bus" {
  function_name = "trigger-event-bus"
  filename      = "lambda.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler = "main.lambda_handler"  
  runtime = "python3.10"  # Adjust as per your runtime
  role    = aws_iam_role.lambda_execution_role.arn
  timeout = 30
}
