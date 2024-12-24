variable "db_type" {
  default     = "db.t3.medium"
  description = "Database Instance Type"
}
variable "db_name" {
  default     = "test"
  description = "Default DB Name"
}

variable "publicly_accessible" {
  default     = true
  description = "Access from public or not"
}
variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
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
variable "skip_final_snapshot" {
  type        = bool
  description = "Skip Final Snapshot or not"
  default     = true
}

variable "ignore_changes_behavior" {
  type    = list(any)
  default = []
}

variable "function_name" {
  default = "promote-read-replica"
  description = "Lambda Function Name"
}
variable "access_key" {
}
variable "secret_key" {
}
