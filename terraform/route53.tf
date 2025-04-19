resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name        = "${var.service_prefix}-hosted-zone"
    Environment = var.default_tags
  }
}

output "hosted_zone_id" {
  description = "The ID of the created hosted zone"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "The name servers of the hosted zone"
  value       = aws_route53_zone.main.name_servers
} 