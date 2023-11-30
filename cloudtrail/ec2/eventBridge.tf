resource "aws_cloudwatch_event_rule" "create_resources" {
  name        = "create_sources"
  description = "Capture each AWS Console Sign In"

  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["AWS API Call via CloudTrail"],
    "detail" : {
      "eventSource" : ["ec2.amazonaws.com"],
      "eventName" : [{
        "prefix" : "Create"
        }
      ]
    }
  })
}


resource "aws_cloudwatch_event_target" "event" {
  rule      = aws_cloudwatch_event_rule.create_resources.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.auto_create_tag.arn
}


resource "aws_cloudwatch_event_rule" "create_resources_2" {
  name        = "run_instances"
  description = "Capture each AWS Console Sign In"

  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["AWS API Call via CloudTrail"],
    "detail" : {
      "eventSource" : ["ec2.amazonaws.com"],
      "eventName" : ["RunInstances"]
    }
  })
}
resource "aws_cloudwatch_event_target" "event_2" {
  rule      = aws_cloudwatch_event_rule.create_resources_2.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.auto_create_tag.arn
}
