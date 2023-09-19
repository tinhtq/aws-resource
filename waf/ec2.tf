resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "aws_ami" "amazon-linux-ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
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

resource "aws_instance" "webserver_1" {
  count                  = length(data.template_file.userdata)
  key_name               = aws_key_pair.example.key_name
  ami                    = data.aws_ami.amazon-ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data              = data.template_file.userdata[count.index].rendered
}

data "template_file" "userdata" {
  count    = 2
  template = file("${path.module}/userdata.tpl")
  vars = {
    number = count.index + 1
  }
}

