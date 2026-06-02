data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  all_azs = data.aws_availability_zones.available.names
  az_ids  = data.aws_availability_zones.available.zone_ids
  filtered_azs = [
    for i, az in local.all_azs : az
    if !contains(var.exclude_az_ids, local.az_ids[i])
  ]
  azs = slice(local.filtered_azs, 0, min(2, length(local.filtered_azs)))
}

# =============================================================================
# VPC
# =============================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.service_name}-vpc"
  }
}

# =============================================================================
# Internet Gateway
# =============================================================================
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-igw"
  }
}

# =============================================================================
# Public Subnets
# =============================================================================
resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.service_name}-public-${local.azs[count.index]}"
    Type = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.service_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(local.azs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Private Subnets
# No NAT Gateway — private subnets use VPC Endpoints for AWS service access.
# =============================================================================
resource "aws_subnet" "private" {
  count = length(local.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + length(local.azs))
  availability_zone = local.azs[count.index]

  tags = {
    Name = "${var.service_name}-private-${local.azs[count.index]}"
    Type = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.service_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count = length(local.azs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
