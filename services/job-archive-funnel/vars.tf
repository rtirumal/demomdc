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

variable "sqs_completed_tasks_visibility_timeout_seconds" {
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)."
  default     = 120
}

variable "sqs_completed_tasks_max_receive_count" {
  description = "The maximum number of times that a message can be received by consumers. When this value is exceeded for a message the message will be automatically sent to the Dead Letter Queue. Only used if var.dead_letter_queue is true."
  default     = 3
}

variable "sqs_unprocessed_tests_visibility_timeout_seconds" {
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)."
  default     = 120
}

variable "sqs_unprocessed_tests_max_receive_count" {
  description = "The maximum number of times that a message can be received by consumers. When this value is exceeded for a message the message will be automatically sent to the Dead Letter Queue. Only used if var.dead_letter_queue is true."
  default     = 3
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
