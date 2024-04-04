resource "aws_eks_cluster" "cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [data.aws_subnet.zone_a.id, data.aws_subnet.zone_b.id]
  }
}

module "eks_self_managed_node_group" {
  source = "github.com/aws-samples/amazon-eks-self-managed-node-group"

  eks_cluster_name = "eks_cluster"
  instance_type    = "t3.medium"
  desired_capacity = 5
  min_size         = 1
  max_size         = 5
  subnets          = [data.aws_subnet.zone_a.id, data.aws_subnet.zone_b.id]

  node_labels = {
    "node.kubernetes.io/node-group" = "node-group-a" # (Optional) node-group name label
  }
  depends_on = [aws_eks_cluster.cluster]
}

