terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      created_by    = var.created_by
      environment   = var.environment_tag
      terraform     = "True"
    }
  }
}

module "networking"{
    source = "../../modules/networking"

    vpc_cidr = var.vpc_cidr
    vpc_name = var.vpc_name

    private_cidrs = var.private_cidrs
    private_subnet_name = var.private_subnet_name

    public_cidrs = var.public_cidrs
    public_subnet_name = var.public_subnet_name

    eip_name = var.eip_name
    internet_gateway_name = var.internet_gateway_name
    nat_gateway_name = var.nat_gateway_name

    private_route_table_name = var.private_route_table_name
    public_route_table_name = var.public_route_table_name
    
    security_groups = var.security_groups
    load_balancer = var.load_balancer
}

module "EKS"{
    source = "../../modules/EKS"

    eks_iam_role_name = var.eks_iam_role_name
    eks_cluster_name = var.eks_cluster_name
}
