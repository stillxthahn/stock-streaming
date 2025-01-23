locals {
  base_name = "${var.prefix}${var.separator}${var.name}"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = local.base_name
  }
}

data "aws_availability_zones" "available" {}

# Create 2 public - 2 private subnet
resource "aws_subnet" "public-01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${local.base_name}-public-subnet-01"
  }
}

resource "aws_subnet" "public-02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${local.base_name}-public-subnet-02"
  }
}

resource "aws_subnet" "private-01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 3)
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${local.base_name}-private-subnet-01"
  }
}

resource "aws_subnet" "private-02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, 4)
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${local.base_name}-private-subnet-02"
  }
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.base_name}-igw"
  }
}

resource "aws_route_table" "public-route-to-igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.base_name}-public-rt"
  }
}

resource "aws_route" "public_subnet_internet_gateway_ipv4" {
  route_table_id         = aws_route_table.public-route-to-igw.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "public_subnet_internet_gateway_ipv6" {
  route_table_id              = aws_route_table.public-route-to-igw.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_AZ1" {
  subnet_id      = aws_subnet.public-01.id
  route_table_id = aws_route_table.public-route-to-igw.id
}

resource "aws_route_table_association" "public_AZ2" {
  subnet_id      = aws_subnet.public-02.id
  route_table_id = aws_route_table.public-route-to-igw.id
}


## Create EIPs ##
resource "aws_eip" "public_AZ1" {
  vpc = true
}

## Create NAT Gateways ##
resource "aws_nat_gateway" "nat_AZ1" {
  allocation_id = aws_eip.public_AZ1.id
  subnet_id     = aws_subnet.public-01.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${local.base_name}-NATGW"
  }
}

## Create NAT Routing tables for the private subnets ##
resource "aws_route_table" "private-route-to-nat-gw_AZ1" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${local.base_name}-private-rt"
  }
}

resource "aws_route" "private_subnet_nat_gateway_AZ1" {
  route_table_id         = aws_route_table.private-route-to-nat-gw_AZ1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_AZ1.id
}

resource "aws_route_table_association" "private_AZ1" {
  subnet_id      = aws_subnet.private-01.id
  route_table_id = aws_route_table.private-route-to-nat-gw_AZ1.id
}

resource "aws_route_table_association" "private_AZ2" {
  subnet_id      = aws_subnet.private-02.id
  route_table_id = aws_route_table.private-route-to-nat-gw_AZ1.id
}
