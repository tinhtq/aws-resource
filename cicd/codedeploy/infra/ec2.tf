resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "aws_ami" "amazon-ubuntu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["*ubuntu-jammy-22.04-amd64-server-*"]
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
  key_name        = aws_key_pair.example.key_name
  ami             = data.aws_ami.amazon-ubuntu.id
  instance_type   = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y wget",
      "sudo apt update -y",
      "sudo apt install -y ruby-full",
      "wget https://aws-codedeploy-ap-southeast-1.s3.ap-southeast-1.amazonaws.com/latest/install",
      "chmod +x ./install",
      "sudo ./install auto",
      "systemctl codedeploy-agent status",
      "sudo apt install nginx -y",
      "sudo systemctl enable nginx",
      "sudo mkdir -p /var/www/my-angular-project",
      "sudo sed -i 's#root\\s\\+/usr/share/nginx/html;#root /var/www/my-angular-project;#' /etc/nginx/nginx.conf",
      "sudo systemctl restart nginx"
    ]
  }
}
