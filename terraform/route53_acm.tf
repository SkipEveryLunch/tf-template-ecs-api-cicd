/**
 * Route53 レコードおよび ACM 証明書の設定
 */

# ACM証明書 (Webアプリケーション用)
resource "aws_acm_certificate" "main" {
  count             = var.create_certificate ? 1 : 0
  domain_name       = local.subdomain
  validation_method = "DNS"

  tags = {
    Name = "${var.service_prefix}-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# APIサブドメイン用のRoute 53 レコード (ALBへのルーティング)
resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.subdomain
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

# DNS検証用レコード (ACM証明書の検証用)
resource "aws_route53_record" "cert_validation" {
  for_each = var.create_certificate ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# 他のresourceの作成順序を管理するためのresource。
# これ自体は何らかのリソースをAWS上に作成するものではない。
# 証明書が正しく検証されるまで依存する他のresourceのapplyを待機させる
resource "aws_acm_certificate_validation" "main" {
  count                   = var.create_certificate ? 1 : 0
  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  # NSレコードの更新が完了してから検証を開始する
  depends_on = [aws_route53domains_registered_domain.main]
}

# 出力変数
output "certificate_arn" {
  description = "The ARN of the certificate"
  value       = var.create_certificate ? aws_acm_certificate.main[0].arn : null
}
