resource "aws_lambda_function" "my_lambda" {
  function_name = "event-bridge-integration"
  
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler" 
  runtime          = "python3.10"           
  
  memory_size      = 128
  timeout          = 30
  environment {
    variables = {
        TABLE_NAME = aws_dynamodb_table.global_table.name
    }
  }
}
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda/main.py" 
  output_path = "./lambda/lambda.zip"
}
