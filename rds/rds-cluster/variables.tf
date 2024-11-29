variable "rds_admin_username" {
  type    = string
  default = "admin"
}
variable "rds_admin_password" {
  type    = string
  default = "password"
}

#engine - (Required) Database engine. Engine values include aurora, aurora-mysql, aurora-postgresql, 
# mysql, neptune, oracle-ee, oracle-se, oracle-se1, oracle-se2, postgres, sqlserver-ee, 
# sqlserver-ex, sqlserver-se, and sqlserver-web docdb, mariadb.
variable "engine" {
  type    = string
  default = "aurora-postgresql"
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "region" {
  type        = string
  description = "Region"
  default     = "us-east-1"
}
variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
