variable "access_key" {
}

variable "secret_key" {
}
variable "solution_stack_name" {
  default = "64bit Amazon Linux 2023 v4.3.1 running Python 3.11"
  description = "Solution Stack Name. https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html"
}
variable "tier" {
  description = "Elastic Beanstalk Environment tier"
  default = "WebServer"
}