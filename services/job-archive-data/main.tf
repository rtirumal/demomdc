# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "${var.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${var.aws_account_id}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE REMOTE STATE STORAGE
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # Only allow this Terraform version. Note that if you upgrade to a newer version, Terraform won't allow you to use an
  # older version, so when you upgrade, you should upgrade everyone on your team and your CI servers all at once.
  required_version = "~> 0.11.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# PULL APP VPC DATA FROM THE TERRAFORM REMOTE STATE
# ---------------------------------------------------------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LOCAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------
locals {
  component_name = "${var.service_name}-data"
}

# ---------------------------------------------------------------------------------------------------------------------
# KMS Master Key for encrypting SSM parameters
# ---------------------------------------------------------------------------------------------------------------------
module "kms_master_key" {
  source = "git::git@github.com:gruntwork-io/module-security.git//modules/kms-master-key?ref=v0.15.4"

  aws_account_id = "${var.aws_account_id}"
  name = "${local.component_name}-${var.service_environment}-kms-key"
  cmk_administrator_iam_arns = "${var.cmk_administrator_iam_arns}"
  cmk_user_iam_arns          = "${var.cmk_user_iam_arns}"
  allow_manage_key_permissions_with_iam = "false"
}
