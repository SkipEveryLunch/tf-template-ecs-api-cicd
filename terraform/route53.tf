resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name        = "${var.service_prefix}-hosted-zone"
    Environment = var.default_tags
  }
}

# Route53ドメインのNSレコードを自動更新
resource "aws_route53domains_registered_domain" "main" {
  domain_name = var.domain_name

  dynamic "name_server" {
    for_each = aws_route53_zone.main.name_servers
    content {
      name = name_server.value
    }
  }

  # レジストラ情報の更新には数分〜十数分かかるため、
  # このリソースの完了を待ってからACM検証に進むようにする
  depends_on = [aws_route53_zone.main]
}

output "hosted_zone_id" {
  description = "The ID of the created hosted zone"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "The name servers of the hosted zone"
  value       = aws_route53_zone.main.name_servers
} 