output "nlb_dns_name" {
  description = "DNS name of the NLB"
  value       = aws_lb.nlb.dns_name
}

output "nlb_alias_name" {
  description = "NLB Alias Record Name in Route53"
  value       = aws_route53_record.alias-record[*].name
}
