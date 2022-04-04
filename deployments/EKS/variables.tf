# Provider Module
variable "aws_access_key" {
  description = "The access key used to access S3 bucket"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "The secret key used to access S3 bucket"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region for resources to be deployed in"
}

variable "created_by" {
  description = "Tag to identify the person that created the resource"
  type        = string
}

variable "environment_tag" {
  description = "Tag to identify the deployment environment"
  type        = string
}

# Networking Module
variable "vpc_cidr" {
  description = "Define the cidr used by the vpc"
  type        = string
}

variable "vpc_name" {
  description = "Tag used to identify the name of the created VPC"
  type        = string
}

variable "private_cidrs" {
  description = "Define the cidrs used in the private subnets"
  type        = list(string)
}

variable "private_subnet_name" {
  description = "Tag used to identify the name of the created private subnets"
  type        = string
}

variable "public_cidrs" {
  description = "Define the cidrs used in the public subnets"
  type        = list(string)
}

variable "public_subnet_name" {
  description = "Tag used to identify the name of the created public subnets"
  type        = string
}

variable "eip_name" {
  description = "Tag used to identify the name of the created Elastic IP"
  type        = string
}

variable "internet_gateway_name" {
  description = "Tag used to identify the name of the created Internet Gateway"
  type        = string
}

variable "nat_gateway_name" {
  description = "Tag used to identify the name of the created NAT Gateway"
  type        = string
}

variable "private_route_table_name" {
  description = "Tag used to identify the name of the created private route table"
  type        = string
}

variable "public_route_table_name" {
  description = "Tag used to identify the name of the created public route table"
  type        = string
}

variable "security_groups" {
  description = "Holds an array of security groups to be used in VPC creation"
  type = list(object({
    description = string

    ingress_cidr_blocks = list(string)
    ingress_from_port   = number
    ingress_to_port     = number
    ingress_protocol    = string

    name = string
  }))
}

variable "load_balancer" {
  description = "Holds information needed to define the load balancer"
  type = object({
    name                       = string
    internal                   = bool
    load_balancer_type         = string
    enable_deletion_protection = bool
  })
}

variable "target_group" {
  description = "Holds information needed to define the target group"
  type = list(object({
    name     = string
    port     = number
    protocol = string
  }))
}

# EKS Module
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

variable "instance_types" {
  description = "The EC2 Instance Types to be used in the EKS Managed Node Group"
  type        = list(string)
}
