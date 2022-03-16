# Define iam role for the eks cluster
resource "aws_iam_role" "eks_iam_role" {
    name = var.eks_iam_role_name
    assume_role_policy = jsonencode({
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
    
    tags = {
        Name = var.eks_iam_role_name
    }
}

resource "aws_eks_cluster" "eks_cluster" {
    name = var.eks_cluster_name
    role_arn = aws_iam_role.eks_iam_role.arn

    vpc_config {
        subnet_ids = [for subnet in zipmap(module.networking.private_subnets, module.networking.public_subnets): subnet.id]
    }
}
