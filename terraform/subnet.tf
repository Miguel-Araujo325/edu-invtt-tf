resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc-edu-invtt.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }

}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc-edu-invtt.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}