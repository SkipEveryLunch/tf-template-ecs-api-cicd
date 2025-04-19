resource "aws_eip" "nat_gateway_a" {
  domain = "vpc"
  tags = {
    Name = "${var.service_prefix}-nat-gateway-a"
  }
}
resource "aws_eip" "nat_gateway_c" {
  domain = "vpc"
  tags = {
    Name = "${var.service_prefix}-nat-gateway-c"
  }
}
