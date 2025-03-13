resource "aws_network_acl" "acl-public-edu-invtt" {
  vpc_id = aws_vpc.vpc-edu-invtt

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32000
    to_port    = 65535
  }

  egress {
    protocol   = "-1"
    rule_no    = *
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "acl-public-edu-invtt"
  }
}

resource "aws_network_acl" "acl-private-edu-invtt" {
  vpc_id = aws_vpc.vpc-edu-invtt

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = 10.0.0.0/24
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = 10.0.0.0/24
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = 10.0.0.0/24
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 400
    action     = "allow"
    cidr_block = 0.0.0.0/0
    from_port  = 32000
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 500
    action     = "allow"
    cidr_block = 10.0.0.0/24
    from_port  = 3306
    to_port    = 3306
  }

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "acl-private-edu-invtt"
  }
}

resource "aws_network_acl_association" "acl-association-public-edu-invtt"{
  subnet_id = aws_subnet.public.id
  network_acl_id = aws_network_acl.acl-public-edu-invtt
  depends_on = [ aws_instance.public_instance_web_server ]
}

resource "aws_network_acl_association" "acl-association-private-edu-invtt" {
  subnet_id = aws_subnet.private.id
  network_acl_id = aws_network_acl.acl-public-edu-invtt
  depends_on = [ aws_instance.private_instance_api ]
}