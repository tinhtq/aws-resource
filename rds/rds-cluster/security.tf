resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow inbound traffic to RDS instance"
  vpc_id      = data.aws_vpc.default.id

  # Inbound rules (allowing access to MySQL/Aurora on port 3306)
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change to allow only trusted IPs or internal traffic
  }

  # Outbound rules (allowing all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}
