#Create the VPC private endpoint
resource "aws_vpc_endpoint" "api_vpc_endpoint" {
  vpc_id              = data.aws_vpc.vpc_id.id
  service_name        = "com.amazonaws.${var.myregion}.execute-api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = var.subnets
  security_group_ids  = [aws_security_group.endpoint_security_group.id]
  policy              = <<EOF
{
    "Statement": [
        {
            "Action": "execute-api:Invoke",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF
}

#Create the security group of the VPC endpoint - Port 443
resource "aws_security_group" "endpoint_security_group" {
  name        = "${var.name_prefix}-${var.env}-endpoint-sg"
  description = "API Endpoint Security Group"
  vpc_id      = data.aws_vpc.vpc_id.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.endpoint_allowed_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.endpoint_allowed_cidr_blocks
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}