resource "aws_lambda_function" "promote-read-replica" {
  function_name = var.function_name
  filename      = "lambda.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler = "main.lambda_handler"  
  runtime = "python3.10"  # Adjust as per your runtime
  role    = aws_iam_role.lambda_execution_role.arn
  timeout = 30
  environment {
    variables = {
      DB_INSTANCE_ID    = aws_rds_cluster.primary.id
      SNS_TOPIC_ARN     = aws_sns_topic.notify.arn
      SUBNET_GROUP_NAME = aws_db_subnet_group.all.name
      LAMBDA_FUNCTION_NAME = var.function_name
    }
}
}