variable "database_username" {
  default = "wordpress"
}
variable "database_password" {
  default = "realWordPassword"
}
variable "database_name" {
  default = "wordpress"
}
variable "availability_zone" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}
variable "target_application_port" {
  default = 80
}
