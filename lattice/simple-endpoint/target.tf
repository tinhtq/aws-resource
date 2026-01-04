# Test EC2 instance for VPC Lattice

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "test" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.lattice.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from VPC Lattice - Instance $(hostname)</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "lattice-test-instance"
  }
}

resource "aws_vpclattice_target_group_attachment" "test" {
  target_group_identifier = aws_vpclattice_target_group.instances.id

  target {
    id   = aws_instance.test.id
    port = 80
  }
}

output "instance_id" {
  description = "ID of the test instance"
  value       = aws_instance.test.id
}

output "instance_private_ip" {
  description = "Private IP of the test instance"
  value       = aws_instance.test.private_ip
}
