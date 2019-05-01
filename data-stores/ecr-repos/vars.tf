# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

#----------------------------------
# Variables expected to be inherited from tf.vars files
#----------------------------------
variable "aws_region" {
  description = "The AWS region in which all resources will be created"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
}

#-----------------------------------
# User Supplied variables
#----------------------------------
variable "repo_names" {
  description = "A list of names of the apps you want to store in ECR. One ECR repository will be created for each name."
  type        = "list"
}

variable "external_account_ids_with_read_access" {
  description = "A list of AWS account IDs for external AWS accounts that should be able to pull images from these ECR repos."
  type        = "list"
  default     = []
}

variable "external_account_ids_with_write_access" {
  description = "A list of AWS account IDs for external AWS accounts that should be able to pull and push images to these ECR repos."
  type        = "list"
  default     = []
}
