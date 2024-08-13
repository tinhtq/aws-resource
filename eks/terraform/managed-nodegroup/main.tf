resource "aws_eks_cluster" "cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [data.aws_subnet.zone_a.id, data.aws_subnet.zone_b.id]
  }
}


