terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC for the service
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-lattice-demo"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "vpc-lattice-private-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vpc-lattice-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "vpc-lattice-rt"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.main.id
}

data "aws_ec2_managed_prefix_list" "vpc_lattice" {
  name = "com.amazonaws.ap-southeast-1.vpc-lattice"
}

resource "aws_security_group" "lattice" {
  name        = "vpc-lattice-sg"
  description = "Security group for VPC Lattice"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.vpc_lattice.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.vpc_lattice.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.vpc_lattice.id]
  }

  tags = {
    Name = "vpc-lattice-sg"
  }
}

# VPC Lattice Service Network
resource "aws_vpclattice_service_network" "main" {
  name      = "demo-service-network"
  auth_type = "NONE"

  tags = {
    Name = "demo-service-network"
  }
}

# VPC Lattice Service
resource "aws_vpclattice_service" "app" {
  name      = "demo-app-service"
  auth_type = "NONE"

  tags = {
    Name = "demo-app-service"
  }
}

# Target Group for EC2 instances
resource "aws_vpclattice_target_group" "instances" {
  name = "demo-instance-tg"
  type = "INSTANCE"

  config {
    vpc_identifier = aws_vpc.main.id
    port           = 80
    protocol       = "HTTP"

    health_check {
      enabled                       = true
      health_check_interval_seconds = 30
      health_check_timeout_seconds  = 5
      healthy_threshold_count       = 2
      unhealthy_threshold_count     = 2
      path                          = "/"
      protocol                      = "HTTP"
    }
  }

  tags = {
    Name = "demo-instance-tg"
  }
}

# Listener for the service
resource "aws_vpclattice_listener" "http" {
  name               = "http-listener"
  protocol           = "HTTP"
  port               = 80
  service_identifier = aws_vpclattice_service.app.id

  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.instances.id
      }
    }
  }

  tags = {
    Name = "http-listener"
  }
}

# Associate service with service network
resource "aws_vpclattice_service_network_service_association" "main" {
  service_identifier         = aws_vpclattice_service.app.id
  service_network_identifier = aws_vpclattice_service_network.main.id

  tags = {
    Name = "demo-service-association"
  }
}

# Associate VPC with service network
resource "aws_vpclattice_service_network_vpc_association" "main" {
  vpc_identifier             = aws_vpc.main.id
  service_network_identifier = aws_vpclattice_service_network.main.id
  security_group_ids         = [aws_security_group.lattice.id]

  tags = {
    Name = "demo-vpc-association"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
