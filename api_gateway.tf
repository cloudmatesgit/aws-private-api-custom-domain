#Create the API Gateway
resource "aws_api_gateway_rest_api" "api_private" {
  name = "${var.name_prefix}-private-api"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": [
                "*"
            ],
            "Condition" : {
                "StringNotEquals": {
                    "aws:SourceVpce": "${aws_vpc_endpoint.api_vpc_endpoint.id}"
                }
            }
        }
    ]
}
EOF

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [aws_vpc_endpoint.api_vpc_endpoint.id]
  }
}

#Create the custom domain and associate the TLS certificate
resource "aws_api_gateway_domain_name" "api_custom_domain" {
  domain_name              = var.acm_cert_fqdn
  regional_certificate_arn = aws_acm_certificate_validation.aws_acm_certificate_validation.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_private.id
}

#Create API Gateway Stage
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_private.id
  stage_name    = var.stage_name
}

#Associate the API Gateway with the custom domain
resource "aws_api_gateway_base_path_mapping" "api_path_mapping" {
  api_id      = aws_api_gateway_rest_api.api_private.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.api_custom_domain.domain_name
}

#Create a resource object for API Gateway
resource "aws_api_gateway_resource" "resource" {
  path_part   = "dev"
  parent_id   = aws_api_gateway_rest_api.api_private.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_private.id
}

#Create a Method
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api_private.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

#Integrate the API Gateway with the Lambda function
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_private.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}




