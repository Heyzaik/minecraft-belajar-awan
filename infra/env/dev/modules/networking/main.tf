# VPC
resource "aws_vpc" "minecraft_vpc" {
  cidr_block = var.vpc_cidr
  tags = { Name = "minecraft-vpc" }
}

# Subnet
resource "aws_subnet" "minecraft_subnet" {
  vpc_id            = aws_vpc.minecraft_vpc.id
  cidr_block        = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-5a"
  tags = { Name = "minecraft-subnet" }
}

# Internet Gateway
resource "aws_internet_gateway" "minecraft_igw" {
  vpc_id = aws_vpc.minecraft_vpc.id
  tags = { Name = "minecraft-igw" }
}

# Route Table
resource "aws_route_table" "minecraft_rt" {
  vpc_id = aws_vpc.minecraft_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft_igw.id
  }
  tags = { Name = "minecraft-rt" }
}

# Route Table Association
resource "aws_route_table_association" "minecraft_rta" {
  subnet_id      = aws_subnet.minecraft_subnet.id
  route_table_id = aws_route_table.minecraft_rt.id
}