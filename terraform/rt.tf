resource "aws_route_table" "rt-public-edu-invtt" {
  vpc_id = aws_vpc.vpc-edu-invtt

  route {
    cidr_block = "10.0.0.0/23"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-edu-invtt
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "rt-public-association-edu-invtt" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt-public-edu-invtt
}

resource "aws_route_table" "rt-private-edu-invtt" {
  vpc_id = aws_vpc.vpc-edu-invtt

  route {
    cidr_block = "10.0.0.0/23"
    gateway_id = "local"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-edu-invtt
  }

  tags = {
    Name = "private-route-table"
  }

}

resource "aws_route_table_association" "rt-private-association-edu-invtt" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt-private-edu-invtt
}