resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
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


module "ec2" {
  for_each               = merge([for obj in var.instances : { for i in range(obj.quantity) : "name-${obj.ami_filter}-${i + 1}" => obj }]...)
  source                 = "./modules"
  key_name               = aws_key_pair.example.key_name
  ami_owner              = each.value.ami_owner
  ami_filter             = each.value.ami_filter
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.instance.id]
}


output "instance_ip_public" {
  value = [for i in values(module.ec2) : i["ip_public"]]
}
