resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name
  lb_target_group_arn    = aws_lb_target_group.target_group.arn
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name                 = "wordpress_asg"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.launch_config.name
  vpc_zone_identifier  = data.aws_subnets.name.ids
  health_check_type    = "ELB"
}

data "aws_subnets" "name" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
