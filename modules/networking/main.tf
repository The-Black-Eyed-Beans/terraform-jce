# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

data "aws_availability_zones" "availability_zones" {
  state = "available"
}

# Create private subnets for microservices
resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.availability_zones.names[count.index]
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("%s_%d", var.private_subnet_name, count.index)
  }
}

# Create public subnet for microservices
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_cidrs)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.availability_zones.names[count.index]
  cidr_block        = var.public_cidrs[count.index]

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

resource "aws_eip" "eips" { # Needed for static ip addressing of NAT Gateway
  count = length(aws_subnet.private_subnet)
  tags = {
    Name = format("%s_%d", var.eip_name, count.index)
  }
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = length(aws_subnet.private_subnet)
  allocation_id = aws_eip.eips[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = var.nat_gateway_name
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internet_gateway]
}

# Private route table
resource "aws_route_table" "private_route_tables" {
  count  = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }

  tags = {
    Name = var.private_route_table_name
  }
}

# Public route table
resource "aws_route_table" "public_route_tables" {
  count  = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = format("%s_%d", var.public_route_table_name, count.index)
  }
}

# Private route table associations
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.private_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

# Public route table associations
resource "aws_route_table_association" "public_route_tables_association" {
  count          = length(var.public_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_tables[count.index].id
}

resource "aws_security_group" "security_group" {
  count  = length(var.security_groups)
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = var.security_groups[count.index].description
    from_port   = var.security_groups[count.index].ingress_from_port
    to_port     = var.security_groups[count.index].ingress_to_port
    protocol    = var.security_groups[count.index].ingress_protocol
    cidr_blocks = var.security_groups[count.index].ingress_cidr_blocks
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.security_groups[count.index].name
  }
}

resource "aws_lb" "load_balancer" {
  name               = var.load_balancer.name
  internal           = var.load_balancer.internal
  load_balancer_type = var.load_balancer.load_balancer_type
  security_groups    = [for security_group in aws_security_group.security_group : security_group.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]

  enable_deletion_protection = var.load_balancer.enable_deletion_protection

  tags = {
    Name = var.load_balancer.name
  }
}

resource "aws_lb_target_group" "target_group" {
  count    = length(var.target_group)
  name     = var.target_group[count.index].name
  port     = var.target_group[count.index].port
  protocol = var.target_group[count.index].protocol
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_listener" "front_end" {
  count             = length(var.target_group)
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "30000"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[count.index].arn
  }
}
