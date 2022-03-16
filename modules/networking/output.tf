output "private_subnets" {
    description = "The ids of the defined public subnets"
    value = aws_subnet.private_subnet
}

output "public_subnets" {
    description = "The ids of the defined public subnets"
    value = aws_subnet.public_subnet
}