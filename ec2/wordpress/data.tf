
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = [true]
  }
}



data "aws_subnet" "zone_a" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-west-2a"
  default_for_az    = true
}

data "aws_subnet" "zone_b" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-west-2b"
  default_for_az    = true
}

data "aws_subnet" "zone_c" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-west-2c"
  default_for_az    = true
}
