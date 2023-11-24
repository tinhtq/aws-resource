data "aws_iam_roles" "roles" {}

data "aws_iam_role" "eks_role" {
  for_each = {
    for name in data.aws_iam_roles.roles.names :
    name => name if startswith(name, "task98_role")
  }  
  name = each.value
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "zone_a" {
  vpc_id = data.aws_vpc.default.id
  availability_zone = "us-east-1a"
  default_for_az = true
}
data "aws_subnet" "zone_b" {
  vpc_id = data.aws_vpc.default.id
  availability_zone = "us-east-1b"
  default_for_az = true
}