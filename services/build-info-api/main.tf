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
# CREATE A SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "build_info_api" {
  name        = "${var.service_name}-${var.service_environment}-sg"
  description = "build-info-api ${var.service_environment} lambda security group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(map("Name", format("%s-%s",var.service_name, var.service_environment)), var.custom_tags)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP RULE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_443_from_offices" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  cidr_blocks = [
    "112.219.109.176/29", # Austin Magento Office
    "12.249.97.180/30",   # Austin Magento Office
    "64.157.241.244/30",  # Austin Magento Office
    "80.169.76.248/30",   # Barcelona Magento Office
    "212.0.126.0/28",     # Barcelona Magento Office
    "149.6.130.48/29",    # Barcelona Magento Office
    "68.170.69.176/29",   # LA Magento Office
    "12.29.13.200/29",    # LA Magento Office
    "12.245.131.196/30",
  ] # LA Magento Office

  security_group_id = "${aws_security_group.build_info_api.id}"
  description       = "Allow Magento offices tcp 443 ingress"
}

resource "aws_security_group_rule" "allow_443_outbound" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]                             #Intended to be HTTPS outbound connections to DynamoDB
  security_group_id = "${aws_security_group.build_info_api.id}"
  description       = "Allow all tcp 443 egress"
}

# ---------------------------------------------------------------------------------------------------------------------
# PULL APP VPC DATA FROM THE TERRAFORM REMOTE STATE
# These templates run on top of the VPCs created by the VPC templates, which store their Terraform state files in an S3
# bucket using remote state storage.
# Note: The values of the variables '${var.service_name}-${var.service_environment}' must match the inventory 
# environment folder name (e.g. /account/region/environment) for this to work. 
# e.g. ${var.service_name}-${var.service_environment} == build-info-api-stage == /account/region/*build-info-api-stage*
# See the README in the inventory for more information about the environment folder.
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.service_name}-${var.service_environment}/vpc/terraform.tfstate"
  }
}
