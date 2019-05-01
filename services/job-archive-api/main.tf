# --------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# --------------------------------------------------------------------------------
provider "aws" {
  region = "${var.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${var.aws_account_id}"]
}

# --------------------------------------------------------------------------------
# CONFIGURE REMOTE STATE STORAGE
# --------------------------------------------------------------------------------
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # Only allow this Terraform version. Note that if you upgrade to a newer version, Terraform won't allow you to use an
  # older version, so when you upgrade, you should upgrade everyone on your team and your CI servers all at once.
  required_version = "~> 0.11.10"
}

# --------------------------------------------------------------------------------
# PULL APP VPC DATA FROM THE TERRAFORM REMOTE STATE
# --------------------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

# --------------------------------------------------------------------------------
# LOCAL VARIABLES
# --------------------------------------------------------------------------------
locals {
  component_name = "${var.service_name}-api"
}

# --------------------------------------------------------------------------------
# SECURITY
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# SECURITY GROUP
# --------------------------------------------------------------------------------
resource "aws_security_group" "job_archive_api" {
  name        = "${local.component_name}-${var.service_environment}-sg"
  description = "Job Archive API ${var.service_environment} lambda security group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(map("Name", format("%s-%s",local.component_name, var.service_environment)), var.custom_tags)}"
}

# --------------------------------------------------------------------------------
# SECURITY GROUP RULES
# --------------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_5432_egress_connections" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.private_persistence_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.job_archive_api.id}"
  description       = "Allow all tcp 5432 egress to Postgres RDS"
}

resource "aws_security_group_rule" "allow_443_outbound" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]                             #Intended to be HTTPS outbound connections to SQS
  security_group_id = "${aws_security_group.job_archive_api.id}"
  description       = "Allow all tcp 443 egress"
}
