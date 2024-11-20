variable "db_type" {
  default     = "t3.micro"
  description = "Database Instance Type"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  type        = list(string)
  description = "RDS AZs"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Stack Region"
}
variable "access_key" {

}
variable "secret_key" {

}
