data "aws_ami" "wordpress" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Wordpress*"]
  }
}
