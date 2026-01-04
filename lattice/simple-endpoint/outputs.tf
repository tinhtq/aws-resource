output "service_network_arn" {
  description = "ARN of the VPC Lattice service network"
  value       = aws_vpclattice_service_network.main.arn
}

output "service_arn" {
  description = "ARN of the VPC Lattice service"
  value       = aws_vpclattice_service.app.arn
}

output "service_dns_entry" {
  description = "DNS entry for the VPC Lattice service"
  value       = aws_vpclattice_service.app.dns_entry
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_vpclattice_target_group.instances.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
