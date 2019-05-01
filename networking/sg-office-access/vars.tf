# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
}

variable "vpc_name" {
  description = "The name of the VPC in which to create the Route 53 Private Hosted Zones."
}

variable "vpc_terraform_state_aws_region" {
  description = "The AWS region of the S3 bucket used to store Terraform remote state"
}

variable "vpc_terraform_state_s3_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
}

variable "vpc_terraform_state_s3_key" {
  description = "The path to the terraform.tfstate file insideof the s3 bucket"
}

variable "tags" {
  description = "Optional mapping of tags to assign to the zone"
  type        = "map"
  default     = {}
}


variable "ports" {
  description = "The ports to apply for ingress rules"
  default = []
}
