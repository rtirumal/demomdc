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

variable "service_name" {
  description = "Service Name"
  default     = "m2cicd-env"
}

variable "service_role" {
  description = "Service Role"
  default     = "arn:aws:iam::995614698185:role/CodeBuild"
}

variable "acct_level_resources_s3_bucket" {
  description = "Account level S3 remote state bucket name"
  default     = "m2cicd-php"
}


variable "acct_level_resources_s3_key" {
  description = "Account level S3 remote state S3 key path"
  default     = "./terraform/terraform.tfstate"
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
  default     = "rtirumal"
}

variable "github_repo" {
  description = "Github Repo to pull code from"
  default     = "new-mdcrepo.git"
}

variable "github_branch" {
  description = "Github Branch to pull code from"
  default     = "master"
}

variable "php_version" {
  description = "PHP Version (e.g. 5.6.31, 7.2.15)"
  default     = "7.1.28"
}

variable "ecr_repo" {
  description = "name of the repo"
  default     = "php"
}