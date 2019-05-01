######################################
# General
######################################

variable "aws_account_id" {
  description = "AWS Account ID"
  default     = ""
}

variable "aws_region" {
  description = "region"
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID"
  default     = ""
}

variable "vpc_name" {
  description = "VPC Name"
  default     = ""
}

variable "endpoint_subnets" {
  description = "Public Subnets"
  default     = []
}

variable "service_name" {
  description = "Service Name"
  default     = ""
}

variable "ci_platform_api_terraform_state_aws_region" {
  description = "ci_platform_api_terraform_state_aws_region"
  default     = ""
}

variable "ci_platform_api_terraform_state_s3_bucket" {
  description = "ci_platform_api_terraform_state_s3_bucket"
  default     = ""
}

variable "ci_platform_api_terraform_state_s3_key" {
  description = "ci_platform_api_terraform_state_s3_key"
  default     = ""
}

######################################
# Endpoint
######################################

variable "ports_egress_to_all" {
  description = "Ports to allow egress to all cidr ranges for"
  default     = []
}

variable "ep_service_name" {
  description = "The ID of the Endpoint Service to point your VPC Endpoint to"
  default     = ""
}

variable "ports_ingress_from_api_ep_sg" {
  description = "Ports to allow ingress to the ep sg from the api sg"
  default     = []
}



######################################
# Route53
######################################

variable "target_alias" {
  description = "Target Alias"
  default     = ""
}

variable "target_profile" {
  description = "Target Profile"
  default     = ""
}

variable "origination_profile" {
  description = "Origination Profile"
  default     = ""
}

variable "hosted_zone_id" {
  description = "Hosted Zone ID in Target Route53"
  default     = ""
}
variable "ttl" {
  description = "TTL for the record entry"
  default     = ""
}

variable "record_type" {
  description = "The Type of Record to enter into Route53"
  default     = ""
}

variable "record_name" {
  description = "The Name of the Record to enter into Route53"
  default     = ""
}