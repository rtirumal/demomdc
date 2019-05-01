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

variable "service_name" {
  description = "Service Name"
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


variable "vpc_engcom_terraform_state_aws_region" {
  description = "vpc aws region"
  default     = ""
}

variable "vpc_engcom_terraform_state_s3_bucket" {
  description = "vpc s3 bucket"
  default     = ""
}

variable "vpc_engcom_terraform_state_s3_key" {
  description = "vpc s3 key"
  default     = ""
}

variable "vpc_jobarchive_terraform_state_aws_region" {
  description = "vpc jobarchive aws region"
  default     = ""
}

variable "vpc_jobarchive_terraform_state_s3_bucket" {
  description = "vpc jobarchive s3 bucket"
  default     = ""
}

variable "vpc_jobarchive_terraform_state_s3_key" {
  description = "vpc jobarchive s3 key"
  default     = ""
}

variable "v1_support_terraform_state_aws_region" {
  description = "v1_support aws region"
  default     = ""
}

variable "v1_support_terraform_state_s3_bucket" {
  description = "v1_support s3 bucket"
  default     = ""
}

variable "v1_support_terraform_state_s3_key" {
  description = "vpc v1_support s3 key"
  default     = ""
}



# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------


variable "ports_ingress_github_apps" {
  description = "ports ingress github apps"
  default     = []
}

variable "ports_egress_private_subnets" {
  description = "ports egress private subnets"
  default     = []
}

variable "ports_egress_testing_service_v1_ep" {
  description = "ports egress testing service v1"
  default     = []
}

variable "ports_egress_jobarchive" {
  description = "ports egress job archive"
  default     = []
}
