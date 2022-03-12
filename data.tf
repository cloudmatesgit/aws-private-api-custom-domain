data "aws_caller_identity" "current" {
}

data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_route53_zone" "aws_route53_zone" {
  name         = var.route53_domain_name
  private_zone = false
}
