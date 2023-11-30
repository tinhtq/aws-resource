data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "cloudtrail-lambda-role-${var.resources}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name   = "allow_ec2_permission"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/files/"
  output_path = "${path.module}/files/lambda_function_payload.zip"
}

resource "aws_lambda_function" "auto_create_tag" {
  filename      = "${path.module}/files/lambda_function_payload.zip"
  function_name = "auto_create_tags_${var.resources}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_create_tag.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.create_resources.arn
}
