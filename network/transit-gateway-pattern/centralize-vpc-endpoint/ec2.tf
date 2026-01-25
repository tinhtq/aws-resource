data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

resource "aws_instance" "ec2_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_a.id
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.vpc_a_sg.id]

  tags = {
    Name = "ec2-instance-1"
  }
}

resource "aws_instance" "ec2_2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_b.id
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.vpc_b_sg.id]

  tags = {
    Name = "ec2-instance-2"
  }
}


resource "aws_instance" "ec2_3" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.subnet_centralized.id
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  
  tags = {
    Name = "ec2-instance-3"
  }
}
