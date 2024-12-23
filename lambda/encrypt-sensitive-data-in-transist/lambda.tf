resource "aws_lambda_function" "hello_lambda" {
  function_name = "hello-function"
  runtime       = "python3.10"
  handler       = "main.lambda_handler" # Filename.function_name
  role          = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      "APP" = "Lambda"
    }
  }
  kms_key_arn = aws_kms_key.default.arn

}
