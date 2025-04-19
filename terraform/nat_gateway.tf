resource "aws_nat_gateway" "a" {
  allocation_id = aws_eip.nat_gateway_a.id
  subnet_id     = aws_subnet.public_a.id
  tags = {
    Name = "${var.service_prefix}-a"
  }
}
resource "aws_nat_gateway" "c" {
  allocation_id = aws_eip.nat_gateway_c.id
  subnet_id     = aws_subnet.public_c.id
  tags = {
    Name = "${var.service_prefix}-c"
  }
}
