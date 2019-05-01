# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE ROUTE TABLE ENTRIES AND NETWORK ACLS FOR A VPC PEERING CONNECTION FROM AN EXTERNAL VPC
# This Terraform template creates route table entries that allow an "internal" VPC you control (e.g. stage, prod) to
# communicate with an "external" VPC controlled by a 3rd party (e.g. a SaaS provider). It is assumed that the 3rd party
# sent you a VPC Peering Connection request that you manually accepted and you have the VPC Peering Connection ID and
# CIDR block details for the 3rd party.

# These templates also create Network ACLs to lock down connectivity between the internal and external VPCs to just
# those ports and subnets you allow. Since each subnet can have only a single Network ACL, and adding a new one would
# replace a previous one, we assume that your subnets already have a Network ACL and require you to pass in their IDs
# as inputs.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# ADD ROUTES FROM THE INTERNAL VPC TO THE EXTERNAL VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route" "internal_to_external" {
  count                     = "${var.num_internal_vpc_route_tables}"
  route_table_id            = "${element(var.internal_vpc_route_table_ids, count.index)}"
  destination_cidr_block    = "${var.external_vpc_cidr_block}"
  vpc_peering_connection_id = "${var.vpc_peering_connection_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ALLOW OUTBOUND REQUESTS FROM THE EXTERNAL VPC ONLY ON SPECIFIED PORTS
# Here, we allow outbound requests to specified ports on the external VPC. Since Network ACLs are stateless, we also
# have to allow inbound requests on ephemeral ports from the external VPC to be able to receive "return traffic"
# (i.e. to be able to receive responses to your outbound requests).
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_network_acl_rule" "allow_outbound_to_external_vpc" {
  count          = "${var.num_network_acl_ids_with_external_vpc_access}"
  network_acl_id = "${element(var.network_acl_ids_with_external_vpc_access, count.index)}"

  # Provide plenty of spacing between rules in case someone needs to insert something between them
  rule_number = "${var.egress_starting_rule_number + (count.index * 5)}"
  egress      = true
  protocol    = "${var.protocol}"
  rule_action = "allow"
  cidr_block  = "${var.external_vpc_cidr_block}"
  from_port   = "${var.outbound_from_port}"
  to_port     = "${var.outbound_to_port}"
}

resource "aws_network_acl_rule" "allow_inbound_return_from_external_vpc" {
  count          = "${var.num_network_acl_ids_with_external_vpc_access}"
  network_acl_id = "${element(var.network_acl_ids_with_external_vpc_access, count.index)}"
  rule_number    = "${var.ingress_starting_rule_number + (count.index * 5)}"
  egress         = false
  protocol       = "${var.protocol}"
  rule_action    = "allow"
  cidr_block     = "${var.external_vpc_cidr_block}"
  from_port      = "${var.ephemeral_from_port}"
  to_port        = "${var.ephemeral_to_port}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DENY ALL OTHER REQUESTS TO/FROM THE EXTERNAL VPC
# Here, we deny all connectivity with the external VPC that isn't allowed above. We do it using a higher-numbered rule,
# as AWS will select the ACL with the lowest number first, so any rule above that's matched will take precedence.
# Technically, we don't need these deny rules at all, as by default, Network ACLs deny all traffic that isn't
# explicitly allowed. However, Network ACLs often have permissive inbound rules to allow for return traffic, so here,
# we ensure that the external VPC cannot take advantage of those inbound rules.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_network_acl_rule" "deny_all_inbound_from_external_vpc" {
  count          = "${var.num_all_network_acl_ids}"
  network_acl_id = "${element(var.all_network_acl_ids, count.index)}"
  rule_number    = "${var.ingress_high_starting_rule_number + (count.index * 5)}"
  egress         = false
  protocol       = "all"
  rule_action    = "deny"
  cidr_block     = "${var.external_vpc_cidr_block}"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "deny_all_outbound_to_external_vpc" {
  count          = "${var.num_all_network_acl_ids}"
  network_acl_id = "${element(var.all_network_acl_ids, count.index)}"
  rule_number    = "${var.egress_high_starting_rule_number + (count.index * 5)}"
  egress         = true
  protocol       = "all"
  rule_action    = "deny"
  cidr_block     = "${var.external_vpc_cidr_block}"
  from_port      = 0
  to_port        = 65535
}
