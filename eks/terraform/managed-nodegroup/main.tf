data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

################################################################################
# AMI SSM Parameter
################################################################################

locals {
  # Just to ensure templating doesn't fail when values are not provided
  ssm_cluster_version = var.cluster_version != null ? var.cluster_version : ""

  # TODO - Temporary stopgap for backwards compatibility until v21.0
  ami_type_to_user_data_type = {
    AL2_x86_64                 = "linux"
    AL2_x86_64_GPU             = "linux"
    AL2_ARM_64                 = "linux"
    BOTTLEROCKET_ARM_64        = "bottlerocket"
    BOTTLEROCKET_x86_64        = "bottlerocket"
    BOTTLEROCKET_ARM_64_NVIDIA = "bottlerocket"
    BOTTLEROCKET_x86_64_NVIDIA = "bottlerocket"
    WINDOWS_CORE_2019_x86_64   = "windows"
    WINDOWS_FULL_2019_x86_64   = "windows"
    WINDOWS_CORE_2022_x86_64   = "windows"
    WINDOWS_FULL_2022_x86_64   = "windows"
    AL2023_x86_64_STANDARD     = "al2023"
    AL2023_ARM_64_STANDARD     = "al2023"
    AL2023_x86_64_NEURON       = "al2023"
    AL2023_x86_64_NVIDIA       = "al2023"
  }

  user_data_type = local.ami_type_to_user_data_type[var.ami_type]

  # Map the AMI type to the respective SSM param path
  ami_type_to_ssm_param = {
    AL2_x86_64                 = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2/recommended/image_id"
    AL2_x86_64_GPU             = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2-gpu/recommended/image_id"
    AL2_ARM_64                 = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2-arm64/recommended/image_id"
    BOTTLEROCKET_ARM_64        = "/aws/service/bottlerocket/aws-k8s-${local.ssm_cluster_version}/arm64/latest/image_id"
    BOTTLEROCKET_x86_64        = "/aws/service/bottlerocket/aws-k8s-${local.ssm_cluster_version}/x86_64/latest/image_id"
    BOTTLEROCKET_ARM_64_NVIDIA = "/aws/service/bottlerocket/aws-k8s-${local.ssm_cluster_version}-nvidia/arm64/latest/image_id"
    BOTTLEROCKET_x86_64_NVIDIA = "/aws/service/bottlerocket/aws-k8s-${local.ssm_cluster_version}-nvidia/x86_64/latest/image_id"
    WINDOWS_CORE_2019_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-EKS_Optimized-${local.ssm_cluster_version}/image_id"
    WINDOWS_FULL_2019_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Core-EKS_Optimized-${local.ssm_cluster_version}/image_id"
    WINDOWS_CORE_2022_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-EKS_Optimized-${local.ssm_cluster_version}/image_id"
    WINDOWS_FULL_2022_x86_64   = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Core-EKS_Optimized-${local.ssm_cluster_version}/image_id"
    AL2023_x86_64_STANDARD     = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
    AL2023_ARM_64_STANDARD     = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2023/arm64/standard/recommended/image_id"
    AL2023_x86_64_NEURON       = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2023/x86_64/neuron/recommended/image_id"
    AL2023_x86_64_NVIDIA       = "/aws/service/eks/optimized-ami/${local.ssm_cluster_version}/amazon-linux-2023/x86_64/nvidia/recommended/image_id"
  }
}

data "aws_ssm_parameter" "ami" {

  name = local.ami_type_to_ssm_param[var.ami_type]
}

################################################################################
# User Data
################################################################################

module "user_data" {
  source                    = "../_user_data"
  platform                  = local.user_data_type
  ami_type                  = var.ami_type
  is_eks_managed_node_group = false

  cluster_name               = var.cluster_name
  cluster_endpoint           = var.cluster_endpoint
  cluster_auth_base64        = var.cluster_auth_base64
  cluster_ip_family          = var.cluster_ip_family
  cluster_service_cidr       = var.cluster_service_cidr
  additional_cluster_dns_ips = var.additional_cluster_dns_ips

  enable_bootstrap_user_data = true
  pre_bootstrap_user_data    = var.pre_bootstrap_user_data
  post_bootstrap_user_data   = var.post_bootstrap_user_data
  bootstrap_extra_args       = var.bootstrap_extra_args
  user_data_template_path    = var.user_data_template_path

  cloudinit_pre_nodeadm  = var.cloudinit_pre_nodeadm
  cloudinit_post_nodeadm = var.cloudinit_post_nodeadm
}

################################################################################
# EFA Support
################################################################################

data "aws_ec2_instance_type" "this" {

  instance_type = var.instance_type
}


################################################################################
# Launch template
################################################################################

resource "aws_launch_template" "this" {
  image_id               = data.aws_ami.eks-worker.id
  name                   = "${var.cluster_name}-eks-cluster-worker-nodes"
  vpc_security_group_ids = ["${aws_security_group.eks-cluster-worker-nodes.id}"]
  key_name               = var.key_name
  instance_type          = var.instance_type
  user_data              = base64encode(element(data.template_file.userdata.*.rendered, count.index))
  ebs_optimized          = var.ebs_optimized

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 50
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Node Group
################################################################################

resource "aws_autoscaling_group" "this" {
  max_size            = var.max_size
  min_size            = var.min_size
  name                = var.cluster_name
  vpc_zone_identifier = var.subnet_ids

  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
      spot_instance_pools                      = 2
    }
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.eks-cluster-worker-nodes.id
        version            = "$$Latest"
      }

      override {
        instance_type = local.host-types[0]
      }

      override {
        instance_type = local.host-types[1]
      }
    }
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.cluster_name
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

}

################################################################################
# IAM Role
################################################################################

locals {

  iam_role_name          = coalesce(var.iam_role_name, "${var.cluster_name}-node-group")
  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  ipv4_cni_policy = { for k, v in {
    AmazonEKS_CNI_Policy = "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
  } : k => v if var.iam_role_attach_cni_policy && var.cluster_ip_family == "ipv4" }
  ipv6_cni_policy = { for k, v in {
    AmazonEKS_CNI_IPv6_Policy = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/AmazonEKS_CNI_IPv6_Policy"
  } : k => v if var.iam_role_attach_cni_policy && var.cluster_ip_family == "ipv6" }
}

data "aws_iam_policy_document" "assume_role_policy" {

  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name        = var.iam_role_name
  name_prefix = var.iam_role_name
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

}

# Policies attached ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in merge(
    {
      AmazonEKSWorkerNodePolicy          = "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy"
      AmazonEC2ContainerRegistryReadOnly = "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly"
    },
    local.ipv4_cni_policy,
    local.ipv6_cni_policy
  ) : k => v }

  policy_arn = each.value
  role       = aws_iam_role.name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in var.iam_role_additional_policies : k => v }

  policy_arn = each.value
  role       = aws_iam_role.name
}

resource "aws_iam_instance_profile" "this" {

  role = aws_iam_role.name

  name        = var.iam_role_name
  name_prefix = var.iam_role_name
  path        = var.iam_role_path


  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# IAM Role Policy
################################################################################


data "aws_iam_policy_document" "role" {

  dynamic "statement" {
    for_each = var.iam_role_policy_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role_policy" "this" {

  name        = var.iam_role_name
  name_prefix = "${var.iam_role_name}-"
  policy      = data.aws_iam_policy_document.role[0].json
  role        = aws_iam_role.id
}



################################################################################
# Access Entry
################################################################################

resource "aws_eks_access_entry" "this" {
  count = var.create_access_entry ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.arn
  type          = local.user_data_type == "windows" ? "EC2_WINDOWS" : "EC2_LINUX"

}

