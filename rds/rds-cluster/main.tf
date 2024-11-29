resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "rds-db-credentials"
  description = "RDS Database Credentials"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = "${var.rds_admin_username}"
    password = "${var.rds_admin_password}"
  })
}

resource "aws_rds_cluster" "my_rds_cluster" {
  cluster_identifier      = "my-aurora-cluster"
  engine                  = "aurora-mysql"
  master_password         = jsondecode(aws_secretsmanager_secret_version.rds_secret_version.secret_string)["password"]
  master_username         = jsondecode(aws_secretsmanager_secret_version.rds_secret_version.secret_string)["username"]
  database_name           = "mydatabase"
  backup_retention_period = 7
  skip_final_snapshot     = true
  storage_encrypted       = true
  enable_http_endpoint    = false
  tags = {
    Name = "my-rds-cluster"
  }
  availability_zones     = var.availability_zones
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.my_subnet_group.name
}

resource "aws_rds_cluster_instance" "my_rds_instance" {
  count              = 2
  cluster_identifier = aws_rds_cluster.my_rds_cluster.cluster_identifier
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.my_rds_cluster.engine
}

resource "aws_db_subnet_group" "my_subnet_group" {
  name        = "rds-subnet-group"
  subnet_ids  = data.aws_subnets.default.ids
  description = "DB subnet group"
}

