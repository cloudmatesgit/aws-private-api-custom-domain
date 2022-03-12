#Create a DNS alias record for the NLB in Route53
resource "aws_route53_record" "alias-record" {
  zone_id         = data.aws_route53_zone.aws_route53_zone.zone_id
  name            = var.acm_cert_fqdn
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_lb.nlb.dns_name
    zone_id                = aws_lb.nlb.zone_id
    evaluate_target_health = true
  }
  depends_on = [aws_lb.nlb]
}

#Verify the ownership of the domain
resource "aws_acm_certificate" "aws_acm_certificate" {
  domain_name       = var.acm_cert_fqdn
  validation_method = "DNS"
}

resource "aws_route53_record" "aws_route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.aws_acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.aws_route53_zone.zone_id
}

resource "aws_acm_certificate_validation" "aws_acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.aws_acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.aws_route53_record : record.fqdn]
}