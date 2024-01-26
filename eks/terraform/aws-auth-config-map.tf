
data "aws_eks_cluster_auth" "selected" {
  name = "eks_cluster"

}

provider "kubernetes" {
  load_config_file       = false
  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.selected.token
}

resource "kubernetes_config_map" "aws_auth" {
  depends_on = [aws_eks_cluster.cluster, module.eks_self_managed_node_group]
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<-EOT
      - rolearn: ${module.eks_self_managed_node_group.role_arn}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
    EOT
  }

}
