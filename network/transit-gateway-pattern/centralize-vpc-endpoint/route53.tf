# Private Hosted Zones
resource "aws_route53_zone" "ssm" {
  name = "ssm.ap-southeast-1.amazonaws.com"
  vpc {
    vpc_id = aws_vpc.centralized_vpc_endpoint.id
  }
  vpc {
    vpc_id = aws_vpc.vpc_a.id
  }
  vpc {
    vpc_id = aws_vpc.vpc_b.id
  }
}

resource "aws_route53_zone" "ssmmessages" {
  name = "ssmmessages.ap-southeast-1.amazonaws.com"
  vpc {
    vpc_id = aws_vpc.centralized_vpc_endpoint.id
  }
  vpc {
    vpc_id = aws_vpc.vpc_a.id
  }
  vpc {
    vpc_id = aws_vpc.vpc_b.id
  }
}

resource "aws_route53_zone" "ec2messages" {
  name = "ec2messages.ap-southeast-1.amazonaws.com"
  vpc {
    vpc_id = aws_vpc.centralized_vpc_endpoint.id
  }
  vpc {
    vpc_id = aws_vpc.vpc_a.id
  }
  vpc {
    vpc_id = aws_vpc.vpc_b.id
  }
}

# Alias Records
resource "aws_route53_record" "ssm" {
  zone_id = aws_route53_zone.ssm.zone_id
  name    = "ssm.ap-southeast-1.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.ssm.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.ssm.dns_entry[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ssmmessages" {
  zone_id = aws_route53_zone.ssmmessages.zone_id
  name    = "ssmmessages.ap-southeast-1.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.ssmmessages.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.ssmmessages.dns_entry[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ec2messages" {
  zone_id = aws_route53_zone.ec2messages.zone_id
  name    = "ec2messages.ap-southeast-1.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.ec2messages.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.ec2messages.dns_entry[0].hosted_zone_id
    evaluate_target_health = false
  }
}
