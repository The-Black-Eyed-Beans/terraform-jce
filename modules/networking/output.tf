output "private_subnet_ids" {
  description = "The ids of the defined private subnets"
  value       = [for subnet in aws_subnet.private_subnet : subnet.id]
}

output "public_subnet_ids" {
  description = "The ids of the defined public subnets"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}
