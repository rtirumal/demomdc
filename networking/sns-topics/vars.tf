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

variable "name" {
  description = "The name of the SNS topic"
}

variable "display_name" {
  description = "The display name of the SNS topic"
  default     = ""
}

variable "allow_publish_accounts" {
  description = "A list of IAM ARNs that will be given the rights to publish to the SNS topic."
  type        = "list"
  default     = []

  # Example:
  # default = [
  #   "arn:aws:iam::123445678910:role/jenkins"
  # ]
}

variable "allow_subscribe_accounts" {
  description = "A list of IAM ARNs that will be given the rights to subscribe to the SNS topic."
  type        = "list"
  default     = []

  # Example:
  # default = [
  #   "arn:aws:iam::123445678910:user/jdoe"
  # ]
}

variable "allow_subscribe_protocols" {
  description = "A list of protocols that can be used to subscribe to the SNS topic."
  type        = "list"

  default = [
    "http",
    "https",
    "email",
    "email-json",
    "sms",
    "sqs",
    "application",
    "lambda",
  ]
}
