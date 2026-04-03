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
