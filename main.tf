resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = local.igw_final_tags
}
#public subnets
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  
  # Optional: Choose a specific data center (AZ)
  availability_zone = local.az_names[count.index]

  tags = merge(
        local.common_tags,
        var.public_subnet_tags,
        {
            Name = "${var.project}-${var.enviornment}-public-${local.az_names[count.index]}"
        },
        var.public_subnet_tags
  )
}

#private subnets
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  
  # Optional: Choose a specific data center (AZ)
  availability_zone = local.az_names[count.index]

  tags = merge(
        local.common_tags,
        var.privatec_subnet_tags,
        {
            Name = "${var.project}-${var.enviornment}-private-${local.az_names[count.index]}"
        },
        var.private_subnet_tags
  )
}

#database subnets
resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  
  # Optional: Choose a specific data center (AZ)
  availability_zone = local.az_names[count.index]

  tags = merge(
        local.common_tags,
        var.database_subnet_tags,
        {
            Name = "${var.project}-${var.enviornment}-database-${local.az_names[count.index]}"
        },
        var.database_subnet_tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
        local.common_tags,
        
        {
            Name = "${var.project}-${var.enviornment}-public"
        },
        var.public_route_table_tags
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
        local.common_tags,
       
        {
            Name = "${var.project}-${var.enviornment}-private"
        },
        var.private_route_table_tags
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
        local.common_tags,
    
        {
            Name = "${var.project}-${var.enviornment}-database"
        },
        var.database_route_table_tags
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
 tags = merge(
        local.common_tags,
    
        {
            Name = "${var.project}-${var.enviornment}-nat"
        },
        var.eip_tags
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Must be a PUBLIC subnet

  tags = merge(
        local.common_tags,
    
        {
            Name = "${var.project}-${var.enviornment}-nat"
        },
        var.nat_gateway_tags
  )

  # To ensure proper ordering, it's a best practice to depend on the IGW
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route" "database" {
  route_table_id         = aws_route_table.databse.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}