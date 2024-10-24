variable "instances" {
  default = [
    { quantity = 0, ami_filter = "al2023-ami-*-x86_64", ami_owner = "amazon" },
    { quantity = 0, ami_filter = "*ubuntu-jammy-22.04-amd64-server-*", ami_owner = "amazon" },
    { quantity = 0, ami_filter = "fedora-coreos-38*-x86_64", ami_owner = "125523088429" },
    { quantity = 1, ami_filter = "CentOS Stream 9 x86_64*", ami_owner = "125523088429" },
    { quantity = 0, ami_filter = "amzn2-ami-kernel-5.10-*-x86_64-gp2", ami_owner = "amazon" },
  ]
}

variable "ssh_file" {
  default = "~/.ssh/id_rsa.pub"
}
variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.medium"
}
# Amazon Linux: al2023-ami-*-x86_64
# Ubuntu:  *ubuntu-jammy-22.04-amd64-server-*
# Fedora  fedora-coreos-38*-x86_64
# Fedora Fedora-Cloud-Base-37*x86_64*
# CentOS centos7-hvm-x86_64
# RedHat RHEL-9.3.0*x86_64*
# variable "ami_filter" {
#   default = "*ubuntu-jammy-22.04-amd64-server-*"
# }
# Amazon Linux: amazon
# Ubuntu: amazon
# Fedora: 125523088429
# CentOs: 247102896272
# RedHat: 309956199498
# variable "ami_owner" {
#   default = "amazon"
# }

variable "vpc_id" {

}
variable "subnet_id" {

}
