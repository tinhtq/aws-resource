data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda/main.py" 
  output_path = "./lambda/lambda.zip"
}
data "aws_caller_identity" "current" {}
