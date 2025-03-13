resource "aws_vpc" "vpc-edu-invtt" {
  cidr_block = "10.0.0.0/23"

  tags = {
    Name = "vpc-edu-invtt"
  }
}