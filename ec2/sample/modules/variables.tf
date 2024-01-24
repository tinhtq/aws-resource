variable "key_name" {}
variable "instance_type" {}
variable "vpc_security_group_ids" {
  type = list(any)
}
variable "ami_owner" {
}
variable "ami_filter" {
}
