resource "aws_cloudwatch_event_rule" "create_resources" {
  name        = "create_resources_${var.resources}"
  description = "Capture each AWS Console Sign In"

  event_pattern = jsonencode({
    "source" : ["aws.elasticloadbalancing"],
    "detail-type" : ["AWS API Call via CloudTrail"],
    "detail" : {
      "eventSource" : ["elasticloadbalancing.amazonaws.com"],
      "eventName" : [{
        "prefix" : "Create"
        }
      ],
      "awsRegion" : ["${var.region}"]
    },

  })
}


resource "aws_cloudwatch_event_target" "event" {
  rule      = aws_cloudwatch_event_rule.create_resources.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.auto_create_tag.arn
}
