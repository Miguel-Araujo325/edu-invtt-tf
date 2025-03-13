resource "aws_internet_gateway" "igw-edu-invtt" {
  vpc_id = aws_vpc.vpc-edu-invtt

  tags = {
    Name = "igw-vpc-edu-invtt"
  }
}