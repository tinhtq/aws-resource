resource "aws_iam_policy" "dynamodb_policy" {
  name        = "DynamoDBPutBatchWritePolicy"
  description = "Policy for allowing PutItem and BatchWriteItem actions on MyGT table"
  
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = "${aws_dynamodb_table.global_table.arn}"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-dynamodb-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = "AllowLambdaAssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}
