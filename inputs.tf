variable "vpc_name" {
  description = "The name of the VPC to deploy resources in - used to for query to find the respective ID."
  type        = string
}

variable "env" {
  description = "A logical name given to represent the environment such as dev, prod, test, etc.."
  type        = string
}

variable "name_prefix" {
  description = "Name prefix used attched to individual resources such as NLB, target group, endpoint, etc.."
  type        = string
  default     = null
}


############## NLB Variables  ################
variable "subnets" {
  description = "The subnets to place the NLB, API gateway and Lambda at"
  type        = list(any)
}
variable "ssl_policy" {
  description = "Security Policy of the NLB."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "health_check" {
  description = "A list of health check parameters of the NLB targets."
  type        = list(map(string))
  default     = []
}

variable "endpoint_allowed_cidr_blocks" {
  description = "Allowed CIDR range in the endpoint security group. default is 10.0.0.0/8"
  type        = list(any)
  default     = ["10.0.0.0/8"]
}

############## API Gateway ###################
variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
}

variable "myregion" {
  description = "The region where to deploy the API Gateway."
  type        = string
}

############ ACM and Route53  ##################
variable "acm_cert_fqdn" {
  description = "The FQDN of the certificate to issue such as (api.example.com)"
  type        = string
}

variable "route53_domain_name" {
  description = "The domain name of the hosted zone such as (example.com)"
  type        = string
}

