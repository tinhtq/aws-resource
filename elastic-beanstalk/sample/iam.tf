resource "aws_iam_role" "elasticbeanstalk_role" {
  name               = "aws-elasticbeanstalk-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach a Policy to the Role
resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.elasticbeanstalk_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleWorkerTier"
}

# Create the Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.elasticbeanstalk_role.name
}

