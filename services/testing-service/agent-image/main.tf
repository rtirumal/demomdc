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

#terraform {
  # The configuration for this backend will be filled in by Terragrunt
 # backend "s3" {}

  # Only allow this Terraform version. Note that if you upgrade to a newer version, Terraform won't allow you to use an
  # older version, so when you upgrade, you should upgrade everyone on your team and your CI servers all at once.
#  required_version = "~> 0.11.10"
#}

#data "terraform_remote_state" "acct_level_resources" {
#backend = "s3"
#
#config {
#  region = "${var.acct_level_resources_region}"
#  bucket = "${var.acct_level_resources_s3_bucket}"
#  key    = "${var.acct_level_resources_s3_key}/terraform.tfstate"
#  }
#}
