output "endpoint" {
  description = "RDS Endpoint"
  value       = aws_rds_cluster.primary.endpoint
}
