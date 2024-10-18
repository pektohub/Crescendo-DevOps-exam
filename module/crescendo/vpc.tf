
###################################### VPC Resource
resource "aws_vpc" "main" {
  cidr_block            = var.vpc_cidr_block
  enable_dns_hostnames  = true

  tags = {
    Name        = "${var.project-name}-VPC"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }
}

###################################### Subnet Resource
resource "aws_subnet" "public_subnet" {
    count                   = length(var.pubnet_cidr_block)
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.pubnet_cidr_block[count.index]
    availability_zone       = element(data.aws_availability_zones.az.names, count.index % length(data.aws_availability_zones.az.names))
    map_public_ip_on_launch = true

    tags = {
      Name        = "${var.project-name}-pubnet-${element(data.aws_availability_zones.az.names, count.index % length(data.aws_availability_zones.az.names))}"
      Environment = var.tags_env
      Manage      = var.tags_manage
    }
}

resource "aws_subnet" "private_subnet" {
    count                   = length(var.prinet_cidr_block)
    vpc_id                  = aws_vpc.main.id
    cidr_block              = var.prinet_cidr_block[count.index]
    availability_zone       = element(data.aws_availability_zones.az.names, count.index % length(data.aws_availability_zones.az.names))
    map_public_ip_on_launch = true

    tags = {
      Name        = "${var.project-name}-prinet-${element(data.aws_availability_zones.az.names, count.index % length(data.aws_availability_zones.az.names))}"
      Environment = var.tags_env
      Manage      = var.tags_manage
    }
}

###################################### Internet Gateway Resource
resource "aws_internet_gateway" "igw" {
  vpc_id        = aws_vpc.main.id

  tags = {
    Name        = "${var.project-name}-internet-gateway"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }
}

###################################### Nat Gateway Resource
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name        = "${var.project-name}-nat-gateway"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }
}

# Elastic IP Resource
resource "aws_eip" "nat_eip" {
  vpc           = true
  depends_on    = [aws_internet_gateway.igw]
  
  tags = {
    Name        = "${var.project-name}-ElasticIP"
    Environment = var.tags_env
    Manage      = var.tags_manage
  }
}

###################################### Route table Resource
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name        = "${var.project-name}-public-routetable"
        Environment = var.tags_env
        Manage      = var.tags_manage
    }
}

resource "aws_route_table_association" "public" {
    count           = length(var.pubnet_cidr_block)      
    subnet_id       = aws_subnet.public_subnet[count.index].id
    route_table_id  = aws_route_table.public.id
}

resource "aws_route" "public_route" {
    route_table_id          = aws_route_table.public.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.igw.id 
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name        = "${var.project-name}-private-routetable"
        Environment = var.tags_env
        Manage      = var.tags_manage
    }
}

resource "aws_route_table_association" "private" {
    count               = length(var.prinet_cidr_block)
    subnet_id           = aws_subnet.private_subnet[count.index].id
    route_table_id      = aws_route_table.private.id
}

resource "aws_route" "private_route" {
    route_table_id          = aws_route_table.private.id
    destination_cidr_block  = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.nat-gateway.id
}