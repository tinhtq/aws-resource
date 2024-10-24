
variable "cluster_name" {
  description = "Name of associated EKS cluster"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "The key name that should be used for the instance"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The type of the instance to launch"
  type        = string
  default     = ""
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = null
}


variable "subnet_ids" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`"
  type        = list(string)
  default     = null
}

variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = 0
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = 3
}
################################################################################
# Access Entry
################################################################################

variable "create_access_entry" {
  description = "Determines whether an access entry is created for the IAM role used by the node group"
  type        = bool
  default     = true
}

variable "iam_role_arn" {
  description = "ARN of the IAM role used by the instance profile. Required when `create_access_entry = true` and `create_iam_instance_profile = false`"
  type        = string
  default     = null
}

variable "cluster_version" {
  description = "Kubernetes cluster version - used to lookup default AMI ID if one is not provided"
  type        = string
  default     = null
}
variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the node group. See the [AWS documentation](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html#AmazonEKS-Type-Nodegroup-amiType) for valid values"
  type        = string
  default     = "AL2_x86_64"
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_attach_cni_policy" {
  description = "Whether to attach the `AmazonEKS_CNI_Policy`/`AmazonEKS_CNI_IPv6_Policy` IAM policy to the IAM IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster"
  type        = bool
  default     = true
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`"
  type        = string
  default     = "ipv4"
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}
variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}
variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role"
  type        = map(string)
  default     = {}
}

variable "iam_role_policy_statements" {
  description = "A list of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) - used for adding specific IAM permissions as needed"
  type        = any
  default     = []
}
