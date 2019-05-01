# ---------------------------------------------------------------------------------------------------------------------
# GENERAL
# ---------------------------------------------------------------------------------------------------------------------

variable "acct_name" {
  description = "Account Name"
  default     = ""
}

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

variable "service_name" {
  description = "Service Name"
  default     = ""
}

variable "service_role" {
  description = "Service Role"
  default     = ""
}
# ---------------------------------------------------------------------------------------------------------------------
# ECR Repo 
# ---------------------------------------------------------------------------------------------------------------------

