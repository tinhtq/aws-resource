# Client instance to test VPC Lattice

resource "aws_instance" "client" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.lattice.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              EOF

  tags = {
    Name = "lattice-client-instance"
  }
}

output "client_instance_id" {
  value = aws_instance.client.id
}

output "test_command" {
  value = "curl http://${aws_vpclattice_service.app.dns_entry[0].domain_name}"
}
