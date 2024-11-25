resource "aws_cloudwatch_log_group" "rds" {
  name = "/aws/rds/cluster/${var.rds_cluster_name}/error"
}
