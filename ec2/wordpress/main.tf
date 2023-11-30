resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "aws_ami" "amazon-ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["*ubuntu-jammy-22.04-amd64-server-*"]
  }
}
resource "aws_security_group" "instance" {
  name = "security-group-instance"
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
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.db]
  vpc_id     = data.aws_vpc.default.id
}

# resource "aws_launch_configuration" "launch_config" {
#   name_prefix     = "wordpress-"
#   image_id        = data.aws_ami.amazon-ubuntu.id
#   key_name        = aws_key_pair.example.key_name
#   instance_type   = "t2.micro"
#   security_groups = [aws_security_group.instance.id]
#   user_data       = data.template_file.userdata.rendered

#   lifecycle {
#     create_before_destroy = true
#   }
#   depends_on = [
#     aws_db_instance.rds_master,
#   ]
# }

data "template_file" "userdata" {
  template = file("${path.module}/files/userdata.tpl")
  vars = {
    database_host     = aws_db_instance.rds_master.address
    database_name     = var.database_name
    database_username = var.database_username
    database_password = var.database_password
  }
}

resource "aws_instance" "server" {
  key_name               = aws_key_pair.example.key_name
  ami                    = data.aws_ami.amazon-ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = data.template_file.userdata.rendered
}
