# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A VPC PEERING CONNECTION
# This Terraform template creates a VPC peering connection and route table entries that allow two VPCs, which are
# normally isolated, to communicate with each other.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

resource "aws_route" "origin_to_destination" {
  count                     = "${var.num_origin_vpc_route_tables}"
  route_table_id            = "${element(var.origin_vpc_route_table_ids, count.index)}"
  destination_cidr_block    = "${var.destination_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD ROUTES FROM THE DESTINATION VPC TO THE ORIGIN VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route" "destination_to_origin" {
  count                     = "${var.num_destination_vpc_route_tables}"
  route_table_id            = "${element(var.destination_vpc_route_table_ids, count.index)}"
  destination_cidr_block    = "${var.origin_vpc_cidr_block}"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
}
