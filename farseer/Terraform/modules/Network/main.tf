##################################################
### VPC ###
##################################################

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.environment}-vpc"
  }
}

##################################################
### GATEWAYS ###
##################################################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-igw"
  }
  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_nat_gateway" "main" {
  count         = var.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id 
  tags = {
    Name = "${var.environment}-natgw-${count.index}"
  }
  depends_on = [
    aws_internet_gateway.main
  ]
}

##################################################
### ELASTIC IPS ###
##################################################

resource "aws_eip" "nat" {
  count = var.nat_gateway_count
  tags = {
    Name = "${var.environment}-nat-eip-${count.index}"
  }
}

##################################################
### SUBNETS ###
##################################################

# Public Subnets
resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.public_subnet_count)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.environment}-private-subnet-${count.index + var.public_subnet_count}"
  }
}

##################################################
### ROUTE TABLES ###
##################################################

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Private Route Tables - One per AZ
resource "aws_route_table" "private" {
  count = length(var.azs)  # One private route table per AZ
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  tags = {
    Name = "${var.environment}-private-rt-${element(var.azs, count.index)}"
  }
}

##################################################
### ROUTE TABLES ASSOCIATIONS ###
##################################################

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table Associations - One route table per AZ
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % length(var.azs)].id
}

##################################################
### ROUTES ###
##################################################

# # Routes for Private Subnets - Point to NAT Gateway in the Same AZ
# resource "aws_route" "private_to_nat" {
#   count                  = length(var.azs)  # One route for each private route table
#   route_table_id         = aws_route_table.private[count.index].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.main[count.index].id
# }

##################################################
### VPC PEERING ###
##################################################

resource "aws_vpc_peering_connection" "main" {
  vpc_id        = data.aws_vpc.default.id
  peer_vpc_id   = aws_vpc.main.id
#  peer_region   = var.peer_region #Commenting out as its not needed now but maybe for future.
  auto_accept   = var.auto_accept_peering
  tags = {
    Name = "${var.environment}-vpc-peering"
  }
}

# Peering Routes for Public Subnets
resource "aws_route" "peering_public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

# Peering Routes for Private Subnets
resource "aws_route" "peering_private" {
  count                  = var.private_subnet_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main.id
}

##################################################
### DEFAULT/OPS VPC ###
##################################################
# Setting Default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to access the default route table of the default VPC
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Add a route for VPC peering to the default route table
resource "aws_route" "peering_default" {
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = aws_vpc.main.cidr_block 
  vpc_peering_connection_id  = aws_vpc_peering_connection.main.id
}