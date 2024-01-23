variable "number_ec2_instance" {
  default = 3
}
# Ubuntu:  *ubuntu-jammy-22.04-amd64-server-*
# Fedora  fedora-coreos-38*-x86_64
# Fedora Fedora-Cloud-Base-37*x86_64*
# CentOS centos7-hvm-x86_64
# RedHat RHEL-9.3.0*x86_64*
variable "ami_filter" {
  default = "RHEL-9.3.0*x86_64*"
}

# Ubuntu: amazon
# Fedora: 125523088429
# CentOs: 247102896272
# RedHat: 309956199498
variable "ami_owner" {
  default = "309956199498"
}