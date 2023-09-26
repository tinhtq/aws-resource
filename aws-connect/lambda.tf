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
    actions = [
      "kinesis:DescribeStream",
      "kinesis:DescribeStreamSummary",
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesis:ListShards",
      "kinesis:ListStreams",
      "kinesis:SubscribeToShard"
    ]
    resources = [aws_kinesis_stream.stream.arn]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "kinesis-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name   = "allow_describe_organization"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/files/lambda/"
  output_path = "${path.module}/files/lambda_function_payload.zip"
}

resource "aws_lambda_function" "get_data_kinesis" {
  filename      = "${path.module}/files/lambda_function_payload.zip"
  function_name = "get-data-kinesis"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"
}

resource "aws_lambda_event_source_mapping" "kinesis" {
  event_source_arn  = aws_kinesis_stream.stream.arn
  function_name     = aws_lambda_function.get_data_kinesis.arn
  starting_position = "LATEST"
}
