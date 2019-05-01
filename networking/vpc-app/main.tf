# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A VPC
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
# CREATE THE VPC
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "git::git@github.com:gruntwork-io/module-vpc.git//modules/vpc-app?ref=v0.5.1"

  vpc_name   = "${var.vpc_name}"
  aws_region = "${var.aws_region}"
  tenancy    = "${var.tenancy}"

  # The number of NAT Gateways to launch for this VPC. For production VPCs, a NAT Gateway should be placed in each
  # Availability Zone (so likely 3 total), whereas for non-prod VPCs, just one Availability Zone (and hence 1 NAT
  # Gateway) will suffice. Warning: You must have at least this number of Elastic IP's to spare. The default AWS limit
  # is 5 per region, but you can request more.
  num_nat_gateways = "${var.num_nat_gateways}"

  # The number of availability zones to use. Default -1 will use all available in the region.
  # One subnet of each type (public, private app, private persistence) will be created in each AZ.
  num_availability_zones = "${var.num_availability_zones}"

  # The IP address range of the VPC in CIDR notation. A prefix of /18 is recommended. Do not use a prefix higher
  # than /27.
  cidr_block = "${var.cidr_block}"

  # The amount of spacing between the different subnet types. 
  subnet_spacing = "${var.subnet_spacing}"

  # Set this to true to allow servers in the private persistence subnets to make outbound requests to the public
  # Internet via a NAT Gateway. If you're only using AWS services (e.g., RDS) you can leave this as false, but if
  # you're running your own data stores in the private persistence subnets, you'll need to set this to true to allow
  # those servers to talk to the AWS APIs (e.g., CloudWatch, IAM, etc).
  # Please now consider using privatelink service endpoints anywhere you can keep the communication private for an 
  # alternative to using AWS APIs over the internet. 
  allow_private_persistence_internet_access = "${var.allow_private_persistence_internet_access}"

  # Some teams may want to explicitly define the exact CIDR blocks used by their subnets. If so, see the vpc-app vars.tf
  # docs at https://github.com/gruntwork-io/module-vpc/blob/master/modules/vpc-app/vars.tf for additional detail.

  # A map of tags to apply to the VPC, Subnets, Route Tables, and Internet Gateway.
  custom_tags = "${var.custom_tags}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE API GATEWAY VPC ENDPOINT
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "execute_api_sg" {
  name        = "${var.vpc_name}-api-gateway-endpoint-sg"
  description = "Security group for the VPCs API Gateway Endpoint"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = "${merge(map("Name", "${var.vpc_name}-api-gateway-endpoint-sg"), var.custom_tags)}"
}

resource "aws_security_group_rule" "execute_api_ingress_from_vpc_cidr" {
  type      = "ingress"
  from_port = "${element(var.api_gateway_interface_ports_ingress_list, count.index)}"
  to_port   = "${element(var.api_gateway_interface_ports_ingress_list, count.index)}"
  protocol  = "tcp"

  # Use same CIDR as VPC
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.execute_api_sg.id}"
  description       = "ingress from private subnets"
  count             = "${length(var.api_gateway_interface_ports_ingress_list)}"
}

resource "aws_security_group_rule" "execute_api_egress_all" {
  type              = "egress"
  from_port         = "${element(var.api_gateway_interface_ports_egress_list, count.index)}"
  to_port           = "${element(var.api_gateway_interface_ports_egress_list, count.index)}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.execute_api_sg.id}"
  description       = "egress to all"
  count             = "${length(var.api_gateway_interface_ports_egress_list)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE API GATEWAY VPC ENDPOINT
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "execute_api_ep" {
  vpc_id              = "${module.vpc.vpc_id}"
  service_name        = "com.amazonaws.us-east-1.execute-api"
  security_group_ids  = ["${aws_security_group.execute_api_sg.id}"]
  vpc_endpoint_type   = "Interface"
  subnet_ids          = ["${module.vpc.private_app_subnet_ids}"]
  auto_accept         = true
  private_dns_enabled = true
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE PARAMETER STORE ENTRY FOR VPC 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ssm_parameter" "execute_api_ep_dns_name" {
  name      = "/${var.vpc_name}/vpc-endpoint/execute-api-ep/dns_name"
  type      = "String"
  value     = "${aws_vpc_endpoint.execute_api_ep.dns_entry.0.dns_name}"
  overwrite = true
  tags      = "${merge(map("Name", "/${var.vpc_name}/vpc-endpoint/execute-api-ep/dns_name"), var.custom_tags)}"
}
