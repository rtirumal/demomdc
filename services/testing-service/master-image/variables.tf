######################################
# General
######################################

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

variable "vpc_id" {
  description = "VPC ID"
  default     = ""
}

variable "vpc_name" {
  description = "VPC Name"
  default     = ""
}

variable "env_name" {
  description = "The Environment Name to deploy the service into.  qa, or dev, or stage or prod for, example"
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

######################################
# Codebuild
######################################

variable "github_owner" {
  description = "Github Org to pull code from"
  default     = ""
}

variable "github_repo" {
  description = "Github Repo to pull code from"
  default     = ""
}

variable "github_branch" {
  description = "Github Branch to pull code from"
  default     = ""
}

variable "master_ecr_repo" {
  description = "Master ECR Repo"
  default     = ""
}

variable "github_master_build_loc" {
  description = "Github Repo for Master Image Buikld Codebuild job to locate the buildspec"
  default     = ""
}

######################################
# S3
######################################

variable "jenkins_keys_bucket_id" {
  description = "Jenkins Keys Bucket ID"
  default     = ""
}

variable "jenkins_keys_bucket_arn" {
  description = "Jenkins Keys Bucket ARN"
  default     = ""
}