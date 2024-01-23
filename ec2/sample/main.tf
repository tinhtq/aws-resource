resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "aws_ami" "amazon-ubuntu" {
  most_recent = true
  owners      = [var.ami_owner]
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = [var.ami_filter]
  }
}

data "aws_vpc" "default" {
  default = true
}
resource "aws_security_group" "instance" {
  name = "security-group-test"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = data.aws_vpc.default.id
}

resource "aws_instance" "example" {
  count = var.number_ec2_instance
  key_name               = aws_key_pair.example.key_name
  ami                    = data.aws_ami.amazon-ubuntu.id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.instance.id]
  root_block_device {
    volume_size = 20
  }
}

output "ip_public" {
  value = aws_instance.example[*].public_ip
}
