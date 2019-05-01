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
  backend          "s3"             {}
  required_version = "~> 0.11.10"
}

# ------------
# Remote State File Data Lookups
# ------------

# VPC of current environment
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

# --------------
# Security Group for VPC Interface Endpoint
# --------------
resource "aws_security_group" "endpoint" {
  name        = "${var.service_name}-ep-sg"
  description = "Security group for the endpoint"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = "${var.custom_tags}"
}

resource "aws_security_group_rule" "egress_80" {
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.private_app_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.endpoint.id}"
  description       = "80 egress to endpoint security group"
}

resource "aws_security_group_rule" "egress_443" {
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.private_app_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.endpoint.id}"
  description       = "443 egress to endpoint security group"
}

resource "aws_security_group_rule" "ingress_80" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.private_app_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.endpoint.id}"
  description       = "ingress from api sg"
}

resource "aws_security_group_rule" "ingress_443" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.private_app_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.endpoint.id}"
  description       = "ingress from api sg"
}

# --------------
# VPC INTERFACE ENDPOINT
# --------------

resource "aws_vpc_endpoint" "endpoint" {
  vpc_id              = "${data.terraform_remote_state.vpc.vpc_id}"
  service_name        = "${var.service_name}"
  security_group_ids  = ["${aws_security_group.endpoint.id}"]
  vpc_endpoint_type   = "Interface"
  subnet_ids          = ["${split(",", length(var.subnet_ids) == 0 ? join(",", var.subnet_ids) : join(",", data.terraform_remote_state.vpc.private_app_subnet_ids))}"]
  private_dns_enabled = "${var.private_dns_enabled}"
  auto_accept         = "${var.auto_accept}"
}

# ---------------------------------------------------------------------------------------------------------------------
# PARAMETER STORE DNS ENTRY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ssm_parameter" "endpoint_dns_name" {
  name      = "/${var.aws_region}/${var.vpc_name}/endpoints/${var.endpoint_name}/dns_name"
  type      = "String"
 // value     = "${aws_vpc_endpoint.endpoint.ep.dns_entry.0.dns_name}"
  value = "${lookup(aws_vpc_endpoint.endpoint.dns_entry[0], "dns_name")}"
  overwrite = true

  # Inlude all package tags and add tags for VPC and VPC_ID
 // tags = "${merge(map("VPC", "${var.vpc_name}"),map("VPC_ID", "${data.remote_terraform_state.vpc.id}") var.custom_tags)}"
  tags = "${merge(map("VPC", "${var.vpc_name}"),map("VPC_ID", "${data.terraform_remote_state.vpc.vpc_id}"), var.custom_tags)}"
}
