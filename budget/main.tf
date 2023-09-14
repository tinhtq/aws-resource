
terraform {
  backend "s3" {
    bucket = "aws-account-tfstate-368886022624"
    key    = "test/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0"
    }
    controltower = {
      source = "idealo/controltower"
      version = "1.3.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "controltower" {
  region = "ap-southeast-1"
}

resource "controltower_aws_account" "account" {
  name                = "${var.first_name} ${var.last_name}"
  email               = "tinhtq+terraform@agileops.vn"
  organizational_unit = "Sandbox"
  close_account_on_delete = true
  organizational_unit_id_on_delete = "ou-l547-j6ulduc0"
  sso {
    first_name = var.first_name
    last_name  = var.last_name
    email      = var.email
  }
}



data "aws_caller_identity" "current" {}

resource "aws_budgets_budget" "account" {
  name         = "${var.first_name}-${var.last_name}-${controltower_aws_account.account.account_id}"
  budget_type  = "COST"
  limit_amount = var.limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name = "LinkedAccount"
    values = [
      controltower_aws_account.account.account_id
    ]
  }

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = var.threshold
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_alarm.arn]
  }
}

resource "aws_sns_topic" "budget_alarm" {
  name = "${var.first_name}-${var.last_name}-${controltower_aws_account.account.account_id}-budget-alarm"
}


resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.budget_alarm.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.budget_alarm.arn,
    ]

    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.budget_alarm.arn,
    ]

    sid = "_budgets_service_access_ID"
  }
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  depends_on = [aws_lambda_function.budget_alarm]
  topic_arn  = aws_sns_topic.budget_alarm.arn
  protocol   = "lambda"
  endpoint   = aws_lambda_function.budget_alarm.arn
}

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
    actions   = ["organizations:DescribeAccount"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "budget_alarm_role_${controltower_aws_account.account.account_id}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name   = "allow_describe_organization"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/dist"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "budget_alarm" {
  filename      = "lambda_function_payload.zip"
  function_name = "${var.first_name}-${var.last_name}-${controltower_aws_account.account.account_id}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs18.x"

  environment {
    variables = {
      channel   = ""
      token     = "",
      accountId = "${controltower_aws_account.account.account_id}"
      limit     = "${var.limit}"
      threshold = "${var.threshold}"
    }
  }
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.budget_alarm.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.budget_alarm.arn
}
