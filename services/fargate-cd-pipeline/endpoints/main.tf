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

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

### API SG
resource "aws_security_group" "execute_api_sg" {
  name        = "${var.vpc_name}-${var.ep_name}-sg"
  description = "Security group for the ${var.ep_name} Endpoint"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = {
    "Name"      = "${var.vpc_name}-${var.ep_name}-sg"
    "Date"      = "${timestamp()}"
    "Terraform" = "yes"
  }
}

resource "aws_security_group_rule" "ingress_from_private_subnets" {
  type              = "ingress"
  from_port         = "${element(var.ports_ingress_private_subnets, count.index)}"
  to_port           = "${element(var.ports_ingress_private_subnets, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.private_app_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.execute_api_sg.id}"
  description       = "ingress from private subnets"
  count             = "${length(var.ports_ingress_private_subnets)}"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = "${element(var.ports_egress_all, count.index)}"
  to_port           = "${element(var.ports_egress_all, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.execute_api_sg.id}"
  description       = "egress to all"
  count             = "${length(var.ports_egress_all)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ENDPOINTS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "execute_api_ep" {
  vpc_id              = "${data.terraform_remote_state.vpc.vpc_id}"
  service_name        = "${var.execute_api_service_name}"
  security_group_ids  = ["${aws_security_group.execute_api_sg.id}"]
  vpc_endpoint_type   = "Interface"
  subnet_ids          = ["${data.terraform_remote_state.vpc.private_app_subnet_ids}"]
  auto_accept         = true
  private_dns_enabled = true
}

# ---------------------------------------------------------------------------------------------------------------------
# PARAMETER STORE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ssm_parameter" "execute_api_ep_dns_name" {
  name      = "/${var.vpc_name}/vpc-endpoint/execute-api-ep/dns_name"
  type      = "String"
  value     = "${aws_vpc_endpoint.execute_api_ep.dns_entry.0.dns_name}"
  overwrite = true
}
