data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./lambda/main.py" 
  output_path = "./lambda.zip"
}
