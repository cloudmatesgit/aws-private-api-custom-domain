#Create the NLB resource
resource "aws_lb" "nlb" {
  name                             = "${var.name_prefix}-${var.env}-nlb"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = var.subnets
}

#Create the NLB Listerner Object - TLS 443
resource "aws_lb_listener" "tls" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate_validation.aws_acm_certificate_validation.certificate_arn
  ssl_policy        = var.ssl_policy

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

#Create the NLB Target group
resource "aws_lb_target_group" "target_group" {
  name        = "${var.name_prefix}-${var.env}-tg"
  port        = 443
  protocol    = "TLS"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc_id.id

  dynamic "health_check" {
    for_each = var.health_check
    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", "/")
      port                = lookup(health_check.value, "port", null)
      protocol            = lookup(health_check.value, "protocol", null)
      timeout             = lookup(health_check.value, "timeout", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      matcher             = lookup(health_check.value, "matcher", "200")
    }
  }
}

#Associate the IP addresses of the VPC endpoints with the NLB Target Group.
locals {
  endpoint_eni_ids = tolist(aws_vpc_endpoint.api_vpc_endpoint.network_interface_ids)
}

#Endpoint ENI 1
data "aws_network_interface" "endpoint_eni_0" {
  id = local.endpoint_eni_ids[0]
}

resource "aws_lb_target_group_attachment" "endpoint_eip_0" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = data.aws_network_interface.endpoint_eni_0.private_ip
  port             = 443
}

#Endpoint ENI 2
data "aws_network_interface" "endpoint_eni_1" {
  id = local.endpoint_eni_ids[1]
}

resource "aws_lb_target_group_attachment" "endpoint_eip_1" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = data.aws_network_interface.endpoint_eni_1.private_ip
  port             = 443
}

#Endpoint ENI 3
data "aws_network_interface" "endpoint_eni_2" {
  id = local.endpoint_eni_ids[2]
}

resource "aws_lb_target_group_attachment" "endpoint_eip_2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = data.aws_network_interface.endpoint_eni_2.private_ip
  port             = 443
}


