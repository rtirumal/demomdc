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

variable "vpc_name" {
  description = "VPC Name"
  default     = ""
}

variable "vpc_terraform_state_aws_region" {
  description = "vpc aws region"
  default     = ""
}

variable "vpc_terraform_state_s3_bucket" {
  description = "vpc s3 bucket"
  default     = ""
}

variable "vpc_terraform_state_s3_key" {
  description = "vpc s3 key"
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

variable "ports_ingress_private_subnets" {
  description = "ports ingress github apps"
  default     = []
}

variable "ports_egress_all" {
  description = "ports egress private subnets"
  default     = []
}

# ---------------------------------------------------------------------------------------------------------------------
# ENDPOINTS
# ---------------------------------------------------------------------------------------------------------------------

variable "execute_api_service_name" {
  description = "job_archive_ep_service_name"
}

variable "ep_name" {
  description = "ep_name"
}
