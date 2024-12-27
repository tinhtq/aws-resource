resource "aws_lambda_function" "current_version" {
  filename         = data.archive_file.lambda_function_1.output_path
  function_name    = "current-version"
  handler          = "lambda_function_1.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = data.archive_file.lambda_function_1.output_base64sha256
}

# Deploy a new Lambda function version
resource "aws_lambda_function" "new_version" {
  filename         =  data.archive_file.lambda_function_2.output_path
  function_name    = "new-version"
  handler          = "lambda_function_2.lambda_handler"
  runtime          = "python3.8"
  role             = aws_iam_role.lambda_exec.arn
  source_code_hash = data.archive_file.lambda_function_2.output_base64sha256
}

# Lambda alias for traffic shifting
resource "aws_lambda_alias" "current" {
  name             = "prod"                      # Alias name
  description      = "Production alias for Lambda"
  function_name    = aws_lambda_function.current_version.function_name
  function_version = aws_lambda_function.current_version.version

  # Routing configuration for traffic shifting
  routing_config {
    additional_version_weights = {
      "2" = 0.1      
    }
  }
}

resource "aws_lambda_alias" "new_version" {
  depends_on       = [aws_lambda_function.new_version]
  name             = aws_lambda_alias.current.name
  description      = "Update alias for Lambda with traffic shifting"
  function_name    = aws_lambda_function.current_version.function_name
  function_version = aws_lambda_function.current_version.version

  # Update routing configuration
  routing_config {
    additional_version_weights = {
      (aws_lambda_function.new_version.version) = 0.1
    }
  }
}
