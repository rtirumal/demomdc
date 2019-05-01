# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A VPC PEERING CONNECTION
# This Terraform template creates a VPC peering connection and route table entries that allow two VPCs, which are
# normally isolated, to communicate with each other.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${var.aws_account_id}"]
}

provider "aws" {
  alias   = "${var.target_alias}"
  profile = "${var.target_profile}"
  region  = "us-east-1"
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


# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE PEERING CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_peering_connection" "vpc_peering_connection" {
  peer_owner_id = "${var.aws_account_id}"
  vpc_id        = "${var.origin_vpc_id}"
  peer_vpc_id   = "${var.destination_vpc_id}"
  auto_accept   = true
  tags          = "${merge(map("Name", "${var.origin_vpc_name}-to-${var.destination_vpc_name}"), var.custom_tags)}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD ROUTES FROM THE ORIGIN VPC TO THE DESTINATION VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route" "origin_subnet1_to_destination" {
  route_table_id            = "${var.origin_vpc_route_table1_id}"
  destination_cidr_block    = "${element(var.destination_subnet_cidr_blocks, count.index)}" # "${var.destination_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
  count = "${length(var.destination_subnet_cidr_blocks)}"
  depends_on                = ["aws_vpc_peering_connection.vpc_peering_connection"]
}

resource "aws_route" "origin_subnet2_to_destination" {
  route_table_id            = "${var.origin_vpc_route_table2_id}"
  destination_cidr_block    = "${element(var.destination_subnet_cidr_blocks, count.index)}" # "${var.destination_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
  count = "${length(var.destination_subnet_cidr_blocks)}"
  depends_on                = ["aws_vpc_peering_connection.vpc_peering_connection"]
}

resource "aws_route" "origin_subnet3_to_destination" {
  route_table_id            = "${var.origin_vpc_route_table3_id}"
  destination_cidr_block    = "${element(var.destination_subnet_cidr_blocks, count.index)}" # "${var.destination_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
  count = "${length(var.destination_subnet_cidr_blocks)}"
  depends_on                = ["aws_vpc_peering_connection.vpc_peering_connection"]
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD ROUTES FROM THE DESTINATION VPC TO THE ORIGIN VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route" "destination_subnet1_to_origin" {
  provider = "aws.${var.target_alias}"
  route_table_id            = "${var.destination_vpc_route_table1_id}"
  destination_cidr_block    = "${element(var.origin_subnet_cidr_blocks, count.index)}"  #"${var.origin_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
  count = "${length(var.origin_subnet_cidr_blocks)}"
  depends_on                = ["aws_vpc_peering_connection.vpc_peering_connection"]
}

resource "aws_route" "destination_subnet2_to_origin" {
  provider = "aws.${var.target_alias}"
  route_table_id            = "${var.destination_vpc_route_table2_id}"
  destination_cidr_block    = "${element(var.origin_subnet_cidr_blocks, count.index)}"  #"${var.origin_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
  count = "${length(var.origin_subnet_cidr_blocks)}"
  depends_on                = ["aws_vpc_peering_connection.vpc_peering_connection"]
}

resource "aws_route" "destination_subnet3_to_origin" {
  provider = "aws.${var.target_alias}"
  route_table_id            = "${var.destination_vpc_route_table3_id}"
  destination_cidr_block    = "${element(var.origin_subnet_cidr_blocks, count.index)}"  #"${var.origin_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
  count = "${length(var.origin_subnet_cidr_blocks)}"
  depends_on                = ["aws_vpc_peering_connection.vpc_peering_connection"]
}
