# --------------------------
# Variables intended to be inherited by inventory global variables
# --------------------------
variable "aws_account_id" {
  description = "This value should be inherited from account.tfvars in the inventory"
}

variable "aws_region" {
  description = "This value should be inherited from region.tfvars in the inventory"
}

variable "terraform_state_aws_region" {
  description = "This value should be inherited from account.tfvars in the inventory"
}

variable "terraform_state_s3_bucket" {
  description = "This value should be inherited from account.tfvars in the inventory"
}

variable "vpc_name" {
  description = "This value should be inherited from env.tfvars in the inventory"
}

# --------------------
# User Required Variables
# --------------------

variable "custom_tags" {
  description = "A map of tags that will be applied to all taggable resources in this package"
  type="map"
}

variable "service_name" {
  description = "(Required) The service name, in the form com.amazonaws.region.service for AWS services."
}
variable "endpoint_name" {
  description = "(Required) The friendly endpoint name, in that will be stored in SSM for other services/programs to lookup, and use."
}
# ----------------------
# User Optional Variables
# ----------------------

variable "subnet_ids" {
  default     = [""]
  description = "(Optional) The ID of one or more subnets in which to create a network interface for the endpoint. By default will use all private-app-subnets in the VPC."
}

variable "auto_accept" {
  default     = "false"
  description = "(Optional) Accept the VPC endpoint (the VPC endpoint and service need to be in the same AWS account)"
}

variable "private_dns_enabled" {
  default     = "false"
  description = "(Optional, AWS services and AWS Marketplace partner services only) Whether or not to associate a private hosted zone with the specified VPC. Defaults to false."
}
