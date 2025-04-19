/**
 * public
 */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.service_prefix}-public"
  }
}
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "public_a" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_a.id
}
resource "aws_route_table_association" "public_c" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_c.id
}

/**
 * private A
 */
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.service_prefix}-private-a"
  }
}
resource "aws_route" "private_a" {
  route_table_id         = aws_route_table.private_a.id
  nat_gateway_id         = aws_nat_gateway.a.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "private_a" {
  route_table_id = aws_route_table.private_a.id
  subnet_id      = aws_subnet.private_a.id
}

/**
 * private C
 */
resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.service_prefix}-private-c"
  }
}
resource "aws_route" "private_c" {
  route_table_id         = aws_route_table.private_c.id
  nat_gateway_id         = aws_nat_gateway.c.id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route_table_association" "private_c" {
  route_table_id = aws_route_table.private_c.id
  subnet_id      = aws_subnet.private_c.id
}
