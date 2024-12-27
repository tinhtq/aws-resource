data "archive_file" "lambda_function_1" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function_1"
  output_path = "${path.module}/lambda_function_1.zip"
}

data "archive_file" "lambda_function_2" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function_2"
  output_path = "${path.module}/lambda_function_2.zip"
}