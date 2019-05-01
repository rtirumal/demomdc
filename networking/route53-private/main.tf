# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE DNS ENTRIES USING ROUTE53
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  # The AWS region in which all resources will be created
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
  required_version = "= 0.11.8"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A ROUTE53 PRIVATE HOSTED ZONE FOR INTERNAL DNS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_zone" "internal_services" {
  name = "${var.internal_services_domain_name}"

  # The VPC to associate with a private hosted zone. Specifying vpc_id will create a private hosted zone.
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = "${var.tags}"
}

# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM REMOTE STATE
# Pull VPC data from the Terraform Remote State
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}
