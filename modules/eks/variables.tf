variable "eks_iam_role_name" {
  description = "The name of the iam role being used by the EKS deployment"
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "eks_node_group_name" {
  description = "The name of the EKS cluster nodegroup"
  type        = string
}

variable "eks_node_group_iam_role_name" {
  description = "The name of the EKS cluster nodegroup IAM Role"
  type        = string
}

variable "private_subnet_ids" {
  description = "Define the cidrs used in the private subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Define the cidrs used in the public subnets"
  type        = list(string)
}

variable "instance_types" {
  description = "The EC2 Instance Types to be used in the EKS Managed Node Group"
  type        = list(string)
}
