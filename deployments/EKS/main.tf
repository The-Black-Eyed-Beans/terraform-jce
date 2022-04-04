terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
  }
}

# Configure the AWS Provider
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  region = var.region
  default_tags {
    tags = {
      created_by  = var.created_by
      environment = var.environment_tag
      terraform   = "True"
    }
  }
}

module "networking" {
  source = "../../modules/networking"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name

  private_cidrs       = var.private_cidrs
  private_subnet_name = var.private_subnet_name

  public_cidrs       = var.public_cidrs
  public_subnet_name = var.public_subnet_name

  eip_name              = var.eip_name
  internet_gateway_name = var.internet_gateway_name
  nat_gateway_name      = var.nat_gateway_name

  private_route_table_name = var.private_route_table_name
  public_route_table_name  = var.public_route_table_name

  security_groups = var.security_groups
  load_balancer   = var.load_balancer
  target_group    = var.target_group
}

module "EKS" {
  source = "../../modules/eks"

  eks_iam_role_name            = var.eks_iam_role_name
  eks_cluster_name             = var.eks_cluster_name
  eks_node_group_name          = var.eks_node_group_name
  eks_node_group_iam_role_name = var.eks_node_group_iam_role_name

  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  instance_types     = var.instance_types
}
