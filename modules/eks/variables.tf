variable "eks_iam_role_name" {
    description = "The name of the iam role being used by the EKS deployment"
    type = string
}

variable "eks_cluster_name"{
    description = "The name of the EKS cluster"
    type = string
}

variable "private_subnet"{
    description = "Define the cidrs used in the private subnets"
    type = list(number)
}

variable "public_subnet"{
    description = "Define the cidrs used in the public subnets"
    type = list(number)
}
