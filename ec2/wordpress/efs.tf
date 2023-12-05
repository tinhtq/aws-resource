resource "aws_efs_file_system" "shared" {
  creation_token = "my-product"
}


resource "aws_efs_access_point" "efs" {
  file_system_id = aws_efs_file_system.shared.id

}


resource "aws_efs_mount_target" "mount_a" {
  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = data.aws_subnet.zone_a.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "mount_b" {
  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = data.aws_subnet.zone_b.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "mount_c" {
  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = data.aws_subnet.zone_c.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name = "security-group-efs"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.db]
  vpc_id     = data.aws_vpc.default.id
}
