# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# Create private subnets for microservices
resource "aws_subnet" "private_subnet" {
  count      = length(var.private_cidrs)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_cidrs[count.index]

  tags = {
    Name = format("%s_%d", var.private_subnet_name, count.index)
  }
}

# Create public subnet for microservices
resource "aws_subnet" "public_subnet" {
  count      = length(var.public_cidrs)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_cidrs[count.index]

  tags = {
    Name = format("%s_%d", var.public_subnet_name, count.index)
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_eip" "afs_eip" { # Needed for static ip addressing of NAT Gateway
    tags = {
        Name = var.eip_name
    }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.afs_eip.id
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = var.nat_gateway_name
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet_gateway]
}

# Private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    count = length(var.private_cidrs)
    cidr_block = var.cidr[count.index]
    nat_gateway_id = aws_nat_gateway.nat_gateway
  }

  tags = {
    Name = var.private_route_table_name
  }
}

# Public route table
resource "aws_route_table" "afs_public_route_table" {
  vpc_id = aws_vpc.afs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = var.public_route_table_name
  }
}

# Private route table associations
resource "aws_route_table_association" "afs_private_route_table_association" {
  count          = length(var.private_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.afs_private_route_table.id
}

# Public route table associations
resource "aws_route_table_association" "afs_public_route_table_association" {
  count          = length(var.public_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.afs_public_route_table.id
}

resource "aws_security_group" "security_group" {
  count      = length(var.security_groups)
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = var.security_groups.description
    cidr_blocks = var.security_groups.ingress_cidr_blocks
    from_port   = var.security_groups.ingress_from_port
    to_port     = var.security_groups.ingress_to_port
    protocol    = var.security_groups.ingress_protocol
  }
  
  tags = {
      Name = var.security_groups.name
  }
}

resource "aws_lb" "load_balancer" {
  name               = var.load_balancer.name
  internal           = var.load_balancer.internal
  load_balancer_type = var.load_balancer.load_balancer_type
  security_groups    = [for security_group in aws_security_group.security_group : security_group.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  enable_deletion_protection = var.load_balancer_enable_deletion_protection
  
  tags = {
      Name = var.load_balancer.name
  }
}
