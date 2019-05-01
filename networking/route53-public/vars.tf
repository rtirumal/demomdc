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

variable "primary_domain_name" {
  description = "The primary domain name (e.g. foo.com) for which to create a Route 53 Public Hosted Zone."
}

# ---------------------------------------------------------------------------------------------------------------------
# DEFINE CONSTANTS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "primary_domain_name_comment" {
  description = "A comment or description of the domain name in var.primary_domain_name."
  default     = "Hosted zone managed by Terraform"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Optional parameters that are set to sane defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "tags" {
  description = "Optional mapping of tags to assign to the zone"
  default     = "{}"
}
