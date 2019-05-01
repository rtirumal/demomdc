######################################
# General
######################################

variable "aws_account_id" {
  description = "AWS Account ID"
  default     = "995614698185"
}

variable "aws_region" {
  description = "region"
  default     = "us-east-1"
}

variable "env_name" {
  description = "The Environment Name to deploy the service into.  qa, or dev, or stage or prod for, example"
  default     = "qa"
}

variable "service_name" {
  description = "Service Name"
  default     = "demoservice"
}

variable "service_role" {
  description = "Service Role"
  default     = "agent"
}

variable "acct_level_resources_s3_bucket" {
  description = "Account level S3 remote state bucket name"
  default     = "demos3bucket"
}

variable "acct_level_resources_s3_key" {
  description = "Account level S3 remote state S3 key path"
  default     = "/usr/bin/s3"
}

variable "acct_level_resources_region" {
  description = "Account level remote state region"
  default     = "us-east-1"
}

######################################
# Codebuild
######################################

variable "github_org" {
  description = "Github Org to pull code from"
  default     = "magento"
}

variable "github_repo" {
  description = "Github Repo to pull code from"
  default     = "pkg-devops"
}

variable "github_branch" {
  description = "Github Branch to pull code from"
  default     = "master"
}

variable "php_version_full" {
  description = "Full PHP Version (e.g. 5.6.31, 7.2.15)"
  default     = "7.2.15"
}

variable "php_version_short" {
  description = "Short PHP Version (e.g. 56, 72)"
  default     = "72"
}
