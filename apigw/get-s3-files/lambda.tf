resource "aws_iam_policy" "lambda_s3_access_policy" {
  name = "lambda_s3_access_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
}


# Step 4: Create the Lambda function (assuming the Lambda ZIP package is uploaded)
resource "aws_lambda_function" "hello_world" {
  function_name = "hello-world"
  filename      = "lambda.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler = "main.lambda_handler"  
  runtime = "python3.10"  # Adjust as per your runtime
  role    = aws_iam_role.lambda_execution_role.arn
  timeout = 30
}
resource "aws_lambda_permission" "api_gw_permission" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.handle_s3_obj.execution_arn}/*/*"
}