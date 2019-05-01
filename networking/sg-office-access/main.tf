# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE a Security Group for managing office access to VPC resources
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
  required_version = "~> 0.11.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM REMOTE STATE
# Pull VPC data from the Terraform Remote State
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.vpc_terraform_state_aws_region}"
    bucket = "${var.vpc_terraform_state_s3_bucket}"
    key    = "${var.vpc_terraform_state_s3_key}/terraform.tfstate"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP TO MANAGE HTTP ACCESS FROM OFFICES/VPN
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "office_access_sg" {
  name        = "${var.vpc_name}-office-access-sg"
  description = "Security group for ingress access from Offices"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = {
    "Name" = "${var.vpc_name}-office-access-sg"
    "Date" = "${timestamp()}"
    "Terraform" = "yes"
  }
}

resource "aws_security_group_rule" "ingress_from_la_internal_old" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["10.236.0.0/20"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "Old la Magento Office ingress access"
  count = "${length(var.ports)}"
}

resource "aws_security_group_rule" "ingress_from_vpn_egress_ip_internal" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["10.235.48.0/21"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "ingress from VPN Internal egress IP"
  count = "${length(var.ports)}"
}

resource "aws_security_group_rule" "ingress_from_all_magento_office_public_egress" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["130.248.0.0/17"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "ingress from all magento offices public"
  count = "${length(var.ports)}"
}

resource "aws_security_group_rule" "ingress_from_magento_austin_office_internal" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["10.32.192.0/19"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "ingress from magento austin office internal"
  count = "${length(var.ports)}"
}

resource "aws_security_group_rule" "ingress_from_magento_barcelona_office_internal" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["10.130.16.0/20"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "ingress from magento barcelona office internal"
  count = "${length(var.ports)}"
}

resource "aws_security_group_rule" "ingress_from_magento_la_office_internal" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["10.33.112.0/20"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "ingress from magento la office internal"
  count = "${length(var.ports)}"
}

resource "aws_security_group_rule" "ingress_from_magento_austin_office_public" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["130.248.38.0/23"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "ingress from magento austin office public"
  count = "${length(var.ports)}"
}

resource "aws_security_group_rule" "ingress_from_magento_barcelona_office_public" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["130.248.52.0/23"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "ingress from magento barcelona office public"
  count = "${length(var.ports)}"
}

resource "aws_security_group_rule" "ingress_from_magento_transit_vpc_us_east" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["52.70.79.41/32"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "ingress from magento transit vpc us-east public"
  count = "${length(var.ports)}"
}

resource "aws_security_group_rule" "ingress_from_magento_transit_vpc_eu_west" {
  type              = "ingress"
  from_port         = "${element(var.ports, count.index)}"
  to_port           = "${element(var.ports, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["54.194.189.78/32"]
  security_group_id = "${aws_security_group.office_access_sg.id}"
  description       = "ingress from magento transit vpc eu-west public"
  count = "${length(var.ports)}"
}
