# ---------------------------------------------------------------------------------------------------------------------
# GENERAL
# ---------------------------------------------------------------------------------------------------------------------


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

variable "vpc_terraform_state_aws_region" {
  description = "vpc_terraform_state_aws_region"
  default     = ""
}

variable "vpc_terraform_state_s3_bucket" {
  description = "vpc_terraform_state_s3_bucket"
  default     = ""
}

variable "vpc_terraform_state_s3_key" {
  description = "vpc_terraform_state_s3_key"
  default     = ""
}

variable "account_terraform_state_aws_region" {
  description = "account_terraform_state_aws_region"
  default     = ""
}

variable "account_terraform_state_s3_bucket" {
  description = "account_terraform_state_s3_bucket"
  default     = ""
}

variable "account_terraform_state_s3_key" {
  description = "account_terraform_state_s3_key"
  default     = ""
}
# ---------------------------------------------------------------------------------------------------------------------
# VPN
# ---------------------------------------------------------------------------------------------------------------------

variable "vpn_type_virginia" {
  description = "Virginia VPN Type"
  default     = ""
}

variable "vpn_type_dublin" {
  description = "Dublin VPN Type"
  default     = ""
}

variable "virginia_tunnel_inside_cidr_1" {
  description = "Virginia Tunnel Inside CIDR 1"
  default     = ""
}

variable "virginia_tunnel_inside_cidr_2" {
  description = "Virginia Tunnel Inside CIDR 2"
  default     = ""
}

variable "dublin_tunnel_inside_cidr_1" {
  description = "Dublin Tunnel Inside CIDR 1"
  default     = ""
}

variable "dublin_tunnel_inside_cidr_2" {
  description = "Dublin Tunnel Inside CIDR 2"
  default     = ""
}


variable "private_route_table_list" {
  description = "private_route_table_list"
  default     = []
}