# ----------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator when calling this
# terraform module.
# ----------------------------------------------------------------------------------------------------------------------

variable "aws_account_id" {
  description = "The ID of the AWS account that should own the peering connection."
}

variable "origin_vpc_id" {
  description = "The ID of the VPC which is the origin of the VPC peering connection."
}

variable "origin_vpc_name" {
  description = "The name of the VPC which is the origin of the VPC peering connection."
}

variable "origin_vpc_cidr_block" {
  description = "The CIDR block (e.g. 10.0.100.0/24) associated with the origin VPC."
}

variable "origin_vpc_route_table_ids" {
  description = "A list of IDs of route tables in the origin VPC that should have routes added pointing to destination VPC."
  type        = "list"
}

variable "num_origin_vpc_route_tables" {
  description = "The number of route table ids in var.origin_vpc_route_table_ids. This should be computable, but due to a but due to a Terraform limitation, we can't: https://github.com/hashicorp/terraform/issues/14677#issuecomment-302772685"
}

variable "destination_vpc_id" {
  description = "The ID of the VPC which is the destination of the VPC peering connection."
}

variable "destination_vpc_name" {
  description = "The name of the VPC which is the destination of the VPC peering connection."
}

variable "destination_vpc_cidr_block" {
  description = "The CIDR block (e.g. 10.0.200.0/24) associated with the destination VPC."
}

variable "destination_vpc_route_table_ids" {
  description = "A list of IDs of route tables in the destination VPC that should have routes added pointing to origin VPC."
  type        = "list"
}

variable "num_destination_vpc_route_tables" {
  description = "The number of route table ids in var.destination_vpc_route_table_ids. This should be computable, but due to a but due to a Terraform limitation, we can't: https://github.com/hashicorp/terraform/issues/14677#issuecomment-302772685"
}

variable "custom_tags" {
  description = "A map of tags to apply to the VPC Peering Connection. The key is the tag name and the value is the tag value. Note that the tag 'Name' is automatically added by this module but may be optionally overwritten by this variable."
  type        = "map"
  default     = {}
}
