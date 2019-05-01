# ----------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator when calling this
# terraform module.
# ----------------------------------------------------------------------------------------------------------------------

variable "aws_account_id" {
  description = "The ID of the AWS account that should own the peering connection."
}

variable "aws_region" {
  description = "The region of the AWS account that should own the peering connection."
}

variable "target_alias" {
  description = "Target Alias"
  default     = ""
}

variable "target_profile" {
  description = "Target Profile"
  default     = ""
}

variable "origin_vpc_id" {
  description = "The ID of the VPC which is the origin of the VPC peering connection."
}

variable "origin_vpc_name" {
  description = "The name of the VPC which is the origin of the VPC peering connection."
}

variable "origin_subnet_cidr_blocks" {
  description = "The CIDR block associated with the origin route tables."
  default = []
}

variable "origin_vpc_route_table1_id" {
  description = "The ID of the first route table in the origin VPC that should have routes added pointing to the destination VPC."
}

variable "origin_vpc_route_table2_id" {
  description = "The ID of the second route table in the origin VPC that should have routes added pointing to the destination VPC."
}

variable "origin_vpc_route_table3_id" {
  description = "The ID of the third route table in the origin VPC that should have routes added pointing to the destination VPC."
}

variable "destination_vpc_id" {
  description = "The ID of the VPC which is the destination of the VPC peering connection."
}

variable "destination_vpc_name" {
  description = "The name of the VPC which is the destination of the VPC peering connection."
}

variable "destination_subnet_cidr_blocks" {
  description = "The CIDR block associated with the destination route tables."
  default = []
}

variable "destination_vpc_route_table1_id" {
  description = "The ID of the first route table in the destination VPC that should have routes added pointing to the origin VPC."
}

variable "destination_vpc_route_table2_id" {
  description = "The ID of the second route table in the destination VPC that should have routes added pointing to the origin VPC."
}


variable "destination_vpc_route_table3_id" {
  description = "The ID of the third route table in the destination VPC that should have routes added pointing to the origin VPC."
}

variable "custom_tags" {
  description = "A map of tags to apply to the VPC Peering Connection. The key is the tag name and the value is the tag value. Note that the tag 'Name' is automatically added by this module but may be optionally overwritten by this variable."
  type        = "map"
  default     = {}
}
