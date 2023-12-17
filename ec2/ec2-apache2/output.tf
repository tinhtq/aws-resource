output "ip_public" {
  value      = aws_instance.example.public_ip
  depends_on = [aws_instance.example]
}
output "ami" {
  value = data.aws_ami.amazon-ubuntu.id
}
