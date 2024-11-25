variable "db_type" {
  default     = "db.t3.medium"
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

variable "rds_cluster_name" {
  default = "primary-rds-cluster"
}
variable "emails" {
  type        = list(string)
  description = "List notification emails"
  default     = ["truongquangtinh1997@gmail.com"]
}
