resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg"
  description = "Allow HTTPS from VPC A and B"
  vpc_id      = aws_vpc.centralized_vpc_endpoint.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "10.1.0.0/16"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoint-sg"
  }
}

resource "aws_security_group" "vpc_a_sg" {
  name        = "vpc-a-sg"
  description = "Allow all egress for VPC A"
  vpc_id      = aws_vpc.vpc_a.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-a-sg"
  }
}

resource "aws_security_group" "vpc_b_sg" {
  name        = "vpc-b-sg"
  description = "Allow all egress for VPC B"
  vpc_id      = aws_vpc.vpc_b.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-b-sg"
  }
}
