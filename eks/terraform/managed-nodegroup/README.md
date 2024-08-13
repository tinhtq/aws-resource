# Create EKS Cluster With Self-hosted Node

Create `terraform.tfstate`

```bash
terraform apply
aws eks update-kubeconfig --region region-code --name my-cluster
```

For example, I deployed the EKS Cluster with the name eks_cluster and region us-east-1.

```bash
aws eks update-kubeconfig --region us-east-1 --name eks_cluster
```
