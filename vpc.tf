
resource "aws_vpc" "demo_vpc" {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "subnet_1" {
  cidr_block        = cidrsubnet(aws_vpc.demo_vpc.cidr_block, 8, 0)
  vpc_id            = aws_vpc.demo_vpc.id
  availability_zone = local.availabiliy_zone_1
}

resource "aws_subnet" "subnet_2" {
  cidr_block        = cidrsubnet(aws_vpc.demo_vpc.cidr_block, 8, 1)
  vpc_id            = aws_vpc.demo_vpc.id
  availability_zone = local.availabiliy_zone_2
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo_vpc.id
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.demo_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
