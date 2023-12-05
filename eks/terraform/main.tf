resource "aws_eks_cluster" "cluster" {
  name     = "eks_cluster"
  role_arn = data.aws_iam_role.eks_role["task98_role_61708.58793198"].arn

  vpc_config {
    subnet_ids = [data.aws_subnet.zone_a.id, data.aws_subnet.zone_b.id]
  }
}