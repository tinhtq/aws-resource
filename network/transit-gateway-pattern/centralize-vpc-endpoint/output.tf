output "vpc_a_id" {
  value = aws_vpc.vpc_a.id
}

output "vpc_b_id" {
  value = aws_vpc.vpc_b.id
}

output "centralized_vpc_id" {
  value = aws_vpc.centralized_vpc_endpoint.id
}
