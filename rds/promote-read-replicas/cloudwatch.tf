resource "aws_cloudwatch_log_group" "rds_logs" {
  name = "/aws/rds/mydb/logs"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    DBInstanceIdentifier = aws_rds_cluster.primary.id
  }

  alarm_description = "Triggers if CPU utilization exceeds 80% for 5 minutes"
}
