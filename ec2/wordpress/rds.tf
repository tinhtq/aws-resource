resource "aws_db_instance" "rds_master" {
  identifier              = "master-rds-instance"
  allocated_storage       = 10
  engine                  = "mysql"
  engine_version          = "5.7.37"
  instance_class          = "db.t3.micro"
  db_name                 = var.database_name
  username                = var.database_username
  password                = var.database_password
  backup_retention_period = 7
  multi_az                = false
  availability_zone       = var.availability_zone[1]
  db_subnet_group_name    = aws_db_subnet_group.database_subnet.id
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.db.id]
  storage_encrypted       = true

  tags = {
    Name = "my-rds-master"
  }
}

# resource "aws_db_instance" "rds_replica" {
#   replicate_source_db    = aws_db_instance.rds_master.identifier
#   instance_class         = "db.t3.micro"
#   identifier             = "replica-rds-instance"
#   skip_final_snapshot    = true
#   multi_az               = false
#   availability_zone      = var.availability_zone[0]
#   vpc_security_group_ids = [aws_security_group.db.id]
#   storage_encrypted      = true

#   tags = {
#     Name = "my-rds-replica"
#   }

# }

resource "aws_db_subnet_group" "database_subnet" {
  name       = "db subnet"
  subnet_ids = data.aws_subnets.subnets.ids
}
data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
resource "aws_security_group" "db" {
  name = "security-group-db"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = data.aws_vpc.default.id
}
