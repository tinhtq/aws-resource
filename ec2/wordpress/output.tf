output "lb_endpoint" {
  value = "http://${aws_lb.load_balancer.dns_name}"
}
