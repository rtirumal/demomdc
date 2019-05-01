# ---------------------------------------------------------------------------------------------------------------------
# GENERAL
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_account_id" {
  description = "AWS Account ID. This value is inherited from the inventory. See account.tfvars file"
  default     = ""
}

variable "aws_region" {
  description = "AWS Region. This value is inherited from the inventory. See region.tfvars file"
  default     = ""
}

variable "api_gateway_name" {
  description = "API Gateway Name"
  default     = ""
}

variable "api_gateway_description" {
  description = "Description of API Gateway"
}

variable "job_archive_artifacts_lambda_arn" {
  description = "ARN of Job Archive Artifacts Lambda Function"
}

variable "job_archive_artifacts_lambda_name" {
  description = "Name of Job Archive Artifacts Lambda Function"
}

variable "job_archive_artifacts_lambda_alias_name" {
  description = "Name of Job Archive Artifacts Lambda Function Alias"
}

variable "job_archive_metadata_lambda_arn" {
  description = "ARN of Job Archive Metadata Lambda Function"
}

variable "job_archive_metadata_lambda_name" {
  description = "Name of Job Archive Metadata Lambda Function"
}

variable "job_archive_metadata_lambda_alias_name" {
  description = "Name of Job Archive Metadata Lambda Function Alias"
}

variable "job_archive_task_lambda_arn" {
  description = "ARN of Job Archive Task Lambda Function"
}

variable "job_archive_task_lambda_name" {
  description = "Name of Job Archive Task Lambda Function"
}

variable "job_archive_task_lambda_alias_name" {
  description = "Name of Job Archive Task Lambda Function Alias"
}

variable "testing_service_citest_lambda_arn" {
  description = "ARN of Testing Service API citest Lambda Function"
}

variable "testing_service_citest_lambda_name" {
  description = "Name of Testing Service API citest Lambda Function"
}

variable "testing_service_citest_lambda_alias_name" {
  description = "Name of Testing Service API citest Lambda Function Alias"
}

variable "environment" {
  description = "Type of environment. Defaults to stage"
  default     = "stage"
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
