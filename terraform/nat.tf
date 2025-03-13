
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-edu-invtt" {
  allocation_id = aws_eip.nat_eip
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "nat-edu-invtt"
  }
}