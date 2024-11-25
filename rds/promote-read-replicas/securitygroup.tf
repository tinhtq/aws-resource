# Security Group
resource "aws_security_group" "rds_postgresql_sg" {
  name        = "rds-postgresql-sg"
  description = "Security group for RDS PostgreSQL cluster"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP range or VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgresql-sg"
  }
}
