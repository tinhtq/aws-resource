resource "aws_cloudwatch_log_group" "rds" {
  name = "/aws/rds/cluster/${var.rds_cluster_name}/error"
}


resource "aws_cloudwatch_metric_alarm" "rds_cpu_alarm" {
  alarm_name          = "rds-cpu-utilization-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 86400 # 1 day in seconds
  statistic           = "Average"
  threshold           = 75 # Set the CPU utilization threshold (in percentage)
  unit                = "Percent"

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster_instance.primary_instance.id
  }
  alarm_description = "Alarm when RDS CPU utilization exceeds 75%"
  actions_enabled   = true

  alarm_actions = [
    aws_sns_topic.notify.arn
  ]
}
