resource "aws_instance" "example" {
  key_name               = var.key_name
  ami                    = data.aws_ami.amazon.id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids
  root_block_device {
    volume_size = 30
  }
  ebs_block_device {
    device_name = "ebs"
    volume_size = var.ebs
    volume_type = "gp2"
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.example.id
  domain   = "vpc"
}


data "aws_ami" "amazon" {
  most_recent = true

  owners = [var.ami_owner]
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = [var.ami_filter]
  }
}

output "ip_public" {
  value = aws_instance.example.public_ip
}
