# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${var.aws_account_id}"]
}

provider "aws" {
  alias   = "${var.target_provider}"
  profile = "${var.target_profile}"
  region  = "us-east-1"
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE REMOTE STATE STORAGE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  required_version = "~> 0.11.10"
}

# ---------------------------------------------------------------------------------------------------------------------
# TERRAFORM REMOTE STATE
# Pull VPC data from the Terraform Remote State
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "ci_platform_api" {
  backend = "s3"

  config {
    region = "${var.ci_platform_api_terraform_state_aws_region}"
    bucket = "${var.ci_platform_api_terraform_state_s3_bucket}"
    key    = "${var.ci_platform_api_terraform_state_s3_key}/terraform.tfstate"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC Endpoint
# in the current VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "testing_service_v1_ep_sg" {
  name        = "${var.vpc_name}-testing-service-v1-ep-sg"
  description = "Security group for the Testing Service V1 Endpoint"
  vpc_id      = "${var.vpc_id}"

  tags = {
    "Name" = "${var.vpc_name}-testing-service-v1-ep-sg"
    "Date" = "${timestamp()}"
    "Terraform" = "yes"
  }
}

resource "aws_security_group_rule" "egress_to_all" {
  type              = "egress"
  from_port         = "${element(var.ports_egress_to_all, count.index)}"
  to_port           = "${element(var.ports_egress_to_all, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.testing_service_v1_ep_sg.id}"
  description       = "egress to all"
  count = "${length(var.ports_egress_to_all)}"
}

resource "aws_security_group_rule" "ingress_from_api_sg" {
  type              = "ingress"
  from_port         = "${element(var.ports_ingress_from_api_ep_sg, count.index)}"
  to_port           = "${element(var.ports_ingress_from_api_ep_sg, count.index)}"
  protocol          = "tcp"
  source_security_group_id       = "${data.terraform_remote_state.ci_platform_api.magento_ci_platform_api_sg_id}"
  security_group_id = "${aws_security_group.testing_service_v1_ep_sg.id}"
  description       = "ingress from api sg"
  count = "${length(var.ports_ingress_from_api_ep_sg)}"
}

resource "aws_vpc_endpoint" "testing_service_v1_ep" {
  vpc_id             = "${var.vpc_id}"
  service_name       = "${var.ep_service_name}"
  security_group_ids = ["${aws_security_group.testing_service_v1_ep_sg.id}"]
  vpc_endpoint_type  = "Interface"
  subnet_ids         = ["${var.endpoint_subnets}"]
}


# ---------------------------------------------------------------------------------------------------------------------
# Route53
# entry in Webdigital for use in the current VPC for sending requests to the Endpoint 
# ---------------------------------------------------------------------------------------------------------------------

module "v1_ep_route53_record" {
  source = "git@github.com:magento/module-route53-cross-account.git"
  aws_account_id = "${var.aws_account_id}"
  aws_region = "${var.aws_region}"
  vpc_id = "${var.vpc_id}"
  target_alias = "${var.target_alias}"
  target_profile = "${var.target_profile}"
  origination_profile = "${var.origination_profile}"
  hosted_zone_id = "${var.hosted_zone_id}"
  ttl = "${var.ttl}"
  record = ["${aws_vpc_endpoint.testing_service_v1_ep.dns_entry.0.dns_name}"]
  record_type = "${var.record_type}"
  record_name = "${var.record_name}"
}
