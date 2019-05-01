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

data "terraform_remote_state" "vpc_engcom" {
  backend = "s3"

  config {
    region = "${var.vpc_engcom_terraform_state_aws_region}"
    bucket = "${var.vpc_engcom_terraform_state_s3_bucket}"
    key    = "${var.vpc_engcom_terraform_state_s3_key}/terraform.tfstate"
  }
}

data "terraform_remote_state" "v1_support" {
  backend = "s3"

  config {
    region = "${var.v1_support_terraform_state_aws_region}"
    bucket = "${var.v1_support_terraform_state_s3_bucket}"
    key    = "${var.v1_support_terraform_state_s3_key}/terraform.tfstate"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

### API SG
resource "aws_security_group" "testing_service_api_sg" {
  name        = "${var.vpc_name}-${var.service_name}-sg"
  description = "Security group for the magento ci platform api lambda function"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = {
    "Name" = "${var.vpc_name}-${var.service_name}-sg"
    "Date" = "${timestamp()}"
    "Terraform" = "yes"
  }
}

resource "aws_security_group_rule" "ingress_from_github_apps" {
  type              = "ingress"
  from_port         = "${element(var.ports_ingress_github_apps, count.index)}"
  to_port           = "${element(var.ports_ingress_github_apps, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc_engcom.private_app_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.testing_service_api_sg.id}"
  description       = "ingress from github apps"
  count = "${length(var.ports_ingress_github_apps)}"
}


resource "aws_security_group_rule" "egress_private_subnets" {
  type              = "egress"
  from_port         = "${element(var.ports_egress_private_subnets, count.index)}"
  to_port           = "${element(var.ports_egress_private_subnets, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.private_app_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.testing_service_api_sg.id}"
  description       = "egress private subnets"
  count = "${length(var.ports_egress_private_subnets)}"
}

resource "aws_security_group_rule" "egress_v1_ep_sg" {
  type              = "egress"
  from_port         = "${element(var.ports_egress_testing_service_v1_ep, count.index)}"
  to_port           = "${element(var.ports_egress_testing_service_v1_ep, count.index)}"
  protocol          = "tcp"
  source_security_group_id       = "${data.terraform_remote_state.v1_support.testing_service_v1_ep_sg_id}"
  security_group_id = "${aws_security_group.testing_service_api_sg.id}"
  description       = "egress testing service v1 ep sg"
  count = "${length(var.ports_egress_testing_service_v1_ep)}"
}

resource "aws_security_group_rule" "egress_to_all" {
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.testing_service_api_sg.id}"
  description       = "egress 443 to all"
}