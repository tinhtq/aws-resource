resource "aws_eks_cluster" "cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks.arn
  version  = "1.31"
  vpc_config {
    subnet_ids = [data.aws_subnet.zone_a.id, data.aws_subnet.zone_b.id]
  }
}

