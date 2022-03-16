variable "vpc_cidr" {
    description = "Define the cidr used by the vpc"
    type = string
}

variable "vpc_name" {
    description = "Tag used to identify the name of the created VPC"
    type = string
}

variable "private_cidrs"{
    description = "Define the cidrs used in the private subnets"
    type = list(string)
}

variable "private_subnet_name"{
    description = "Tag used to identify the name of the created private subnets"
    type = string
}

variable "public_cidrs"{
    description = "Define the cidrs used in the public subnets"
    type = list(string)
}

variable "public_subnet_name"{
    description = "Tag used to identify the name of the created public subnets"
    type = string
}

variable "eip_name"{
    description = "Tag used to identify the name of the created Elastic IP"
    type = string
}

variable "internet_gateway_name"{
    description = "Tag used to identify the name of the created Internet Gateway"
    type = string
}

variable "nat_gateway_name"{
    description = "Tag used to identify the name of the created NAT Gateway"
    type = string
}

variable "private_route_table_name"{
    description = "Tag used to identify the name of the created private route table"
    type = string
}

variable "public_route_table_name"{
    description = "Tag used to identify the name of the created public route table"
    type = string
}

variable "security_groups"{
    description = "Holds an array of security groups to be used in VPC creation"
    type=list(object({
        description = string

        ingress_cidr_blocks = list(string)
        ingress_from_port = number
        ingress_to_port = number
        ingress_protocol = string

        name = string
    }))
}

variable "load_balancer"{
    description = "Holds information needed to define the load balancer"
    type=list(object({
        name = string
        internal = bool
        load_balancer_type = string
        enable_deletion_protection = bool
    }))
}
