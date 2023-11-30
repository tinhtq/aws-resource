# output "lb_endpoint" {
#   value = "http://${aws_lb.load_balancer.dns_name}"
# }
output "public_ip" {
  value = aws_instance.server.public_ip
}
