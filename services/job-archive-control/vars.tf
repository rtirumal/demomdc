# --------------------------------------------------------------------------------
# INHERITED PARAMETERS
# These variables are required. They are intended to be passed in via global vars 
# files for the account.
# --------------------------------------------------------------------------------
variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources. Intended to be inherited from account.tfvars"
}

variable "aws_region" {
  description = "The AWS region in which all resources will be created. Intended to be inherited from region.tfvars"
}

variable "terraform_state_aws_region" {
  description = "This value is intended to be inherited from the account.tfvars file in the inventory repo"
}

variable "terraform_state_s3_bucket" { 
  description = "This value is intended to be inherited from the account.tfvars file in the inventory repo"
}

variable "vpc_name" {
  description = "VPC name. Used in state file lookup. Usually inherited from env.tfvars file."
}

# --------------------------------------------------------------------------------
# COMMON USER PARAMETERS
# These variables are required. A value must be passed in.
# --------------------------------------------------------------------------------
variable "service_name" {
  description = "The Name of the service (without environment designation). Also used to create the Name tag of all service resources in this module."
  default     = "job-archive"
}

variable "service_environment" {
  description = "Valid values for this variable are 'stage' or 'prod'. Also used to construct Name of any service resources in this package."
  default     = "stage"
}

variable "allow_publish_accounts" {
  description = ""
  type = "list"
}

variable "allow_subscribe_accounts" {
  description = ""
  type = "list"
}

variable "allow_subscribe_protocols" {
  description = ""
  type = "list"
}

variable "cmk_administrator_iam_arns" {
  description = "A list of IAM ARNs for users who should be given administrator access to this CMK (e.g. arn:aws:iam::<aws-account-id>:user/<iam-user-arn>)."
  type = "list"
}

variable "cmk_user_iam_arns" {
  description = "A list of IAM ARNs for users who should be given permissions to use this CMK (e.g. arn:aws:iam::<aws-account-id>:user/<iam-user-arn>)."
  type = "list"
}

# --------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# --------------------------------------------------------------------------------
variable "custom_tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
