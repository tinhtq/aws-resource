

resource "aws_eks_cluster" "cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.31"
  vpc_config {
    subnet_ids = [data.aws_subnet.zone_a.id, data.aws_subnet.zone_b.id]
  }
}


resource "aws_autoscaling_policy" "bat" {
  name        = "eks_dynamic_scaling"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"

    }
    target_value = 60
  }
  autoscaling_group_name = module.eks_self_managed_node_group.name
}
