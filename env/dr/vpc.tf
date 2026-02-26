resource "aws_vpc" "dr" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "dr-vpc"
  }
}

resource "aws_subnet" "dr_private_1" {
  vpc_id            = aws_vpc.dr.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "dr-private-1"
  }
}

resource "aws_subnet" "dr_private_2" {
  vpc_id            = aws_vpc.dr.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "dr-private-2"
  }
}

resource "aws_db_subnet_group" "dr" {
  name = "dr-subnet-group"

  subnet_ids = [
    aws_subnet.dr_private_1.id,
    aws_subnet.dr_private_2.id
  ]

  tags = {
    Name = "dr-subnet-group"
  }
}

resource "aws_security_group" "dr_rds_sg" {
  name   = "dr-rds-sg"
  vpc_id = aws_vpc.dr.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}