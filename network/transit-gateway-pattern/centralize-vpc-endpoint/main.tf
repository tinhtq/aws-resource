resource "aws_vpc" "vpc_a" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "transit-gw-vpc-a"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id     = aws_vpc.vpc_a.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "transit-gw-subnet-a"
  }
}

resource "aws_route_table" "rt_a" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block         = "10.2.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.vpc_endpoint.id
  }

  tags = {
    Name = "transit-gw-rt-a"
  }
}

resource "aws_route_table_association" "rta_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rt_a.id
}

resource "aws_vpc" "vpc_b" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "transit-gw-vpc-b"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id     = aws_vpc.vpc_b.id
  cidr_block = "10.1.1.0/24"
  tags = {
    Name = "transit-gw-subnet-b"
  }
}

resource "aws_route_table" "rt_b" {
  vpc_id = aws_vpc.vpc_b.id

  route {
    cidr_block         = "10.2.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.vpc_endpoint.id
  }

  tags = {
    Name = "transit-gw-rt-b"
  }
}

resource "aws_route_table_association" "rta_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.rt_b.id
}

resource "aws_ec2_transit_gateway" "vpc_endpoint" {
  description = "Transit Gateway for VPC A and VPC B to list VPC endpoints"
  tags = {
    Name = "transit-gw-vpc-endpoint"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_a_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.vpc_endpoint.id
  vpc_id             = aws_vpc.vpc_a.id
  subnet_ids         = [aws_subnet.subnet_a.id]

  tags = {
    Name = "transit-gw-vpc-a-attachment"
  }

}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_b_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.vpc_endpoint.id
  vpc_id             = aws_vpc.vpc_b.id
  subnet_ids         = [aws_subnet.subnet_b.id]

  tags = {
    Name = "transit-gw-vpc-b-attachment"
  }

}


resource "aws_vpc" "centralized_vpc_endpoint" {
  cidr_block           = "10.2.0.0/16"

  tags = {
    Name = "transit-gw-centralized-vpc-endpoint"
  }
}

resource "aws_subnet" "subnet_centralized" {
  vpc_id     = aws_vpc.centralized_vpc_endpoint.id
  cidr_block = "10.2.1.0/24"

  tags = {
    Name = "transit-gw-centralized-subnet"
  }
}

resource "aws_route_table" "rt_centralized" {
  vpc_id = aws_vpc.centralized_vpc_endpoint.id

  route {
    cidr_block         = "10.0.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.vpc_endpoint.id
  }

  route {
    cidr_block         = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.vpc_endpoint.id
  }

  tags = {
    Name = "transit-gw-rt-centralized"
  }
}

resource "aws_route_table_association" "rta_centralized" {
  subnet_id      = aws_subnet.subnet_centralized.id
  route_table_id = aws_route_table.rt_centralized.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_centralized_endpoint_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.vpc_endpoint.id
  vpc_id             = aws_vpc.centralized_vpc_endpoint.id
  subnet_ids         = [aws_subnet.subnet_centralized.id]

  tags = {
    Name = "transit-gw-centralized-vpc-attachment"
  }

}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.centralized_vpc_endpoint.id
  service_name        = "com.amazonaws.ap-southeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.subnet_centralized.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name = "ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.centralized_vpc_endpoint.id
  service_name        = "com.amazonaws.ap-southeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.subnet_centralized.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name = "ssmmessages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.centralized_vpc_endpoint.id
  service_name        = "com.amazonaws.ap-southeast-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.subnet_centralized.id]
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name = "ec2messages-endpoint"
  }
}
