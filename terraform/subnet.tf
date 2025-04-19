resource "aws_subnet" "public_a" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "${var.service_prefix}-public-a"
  }
}
resource "aws_subnet" "public_c" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "${var.service_prefix}-public-c"
  }
}

resource "aws_subnet" "private_a" {
  cidr_block              = "10.0.10.0/24"
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "${var.service_prefix}-private-a"
  }
}
resource "aws_subnet" "private_c" {
  cidr_block              = "10.0.11.0/24"
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = false
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "${var.service_prefix}-private-c"
  }
}
