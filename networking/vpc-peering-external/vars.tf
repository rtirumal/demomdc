# ----------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator when calling this
# terraform module.
# ----------------------------------------------------------------------------------------------------------------------

variable "vpc_peering_connection_id" {
  description = "The ID of the VPC Peering Connection between the internal VPC and the external VPC. Typically, the 3rd party who owns the external VPC will send you a VPC Peering Connection request that you must manually accept in the AWS console. Once you accept it, you'll be able to see the ID."
}

variable "external_vpc_cidr_block" {
  description = "The IP address range of the external VPC in CIDR notation (e.g. 10.0.2.0/18)"
}

variable "protocol" {
  description = "The protocol to allow in communication between the internal and external VPC (e.g. tcp)"
}

variable "outbound_from_port" {
  description = "Allow communication between the internal and external VPC on ports between var.outbound_from_port and var.outbound_to_port."
}

variable "outbound_to_port" {
  description = "Allow communication between the internal and external VPC on ports between var.outbound_from_port and var.outbound_to_port."
}

variable "internal_vpc_route_table_ids" {
  description = "A list of route table IDs for the internal VPC that you wish to be able to talk to the external VPC"
  type        = "list"
}

variable "num_internal_vpc_route_tables" {
  description = "The number of route table IDs in var.internal_vpc_route_table_ids. We should be able to compute this automatically, but due to a Terraform limitation, we can't: https://github.com/hashicorp/terraform/issues/14677#issuecomment-302772685"
}

variable "network_acl_ids_with_external_vpc_access" {
  description = "A list of IDs of Network ACLs that should have permissions added to them to allow access to the external VPC. We assume you already have Network ACLs on your subnets and that you pass in the IDs here. We cannot create the Network ACLs for you, as each subnet can only be associated with one Network ACL and there is no way to know in Terraform if yours already has one."
  type        = "list"
}

variable "num_network_acl_ids_with_external_vpc_access" {
  description = "The number of IDs in var.network_acl_ids_with_external_vpc_access. We should be able to compute this automatically, but due to a Terraform limitation, we can't: https://github.com/hashicorp/terraform/issues/14677#issuecomment-302772685"
}

variable "all_network_acl_ids" {
  description = "A list of IDs of all Network ACLs in your VPC. This is used to add a global DENY rule that prevents inbound traffic from the external VPC, other than anything explicitly allowed."
  type        = "list"
}

variable "num_all_network_acl_ids" {
  description = "The number of IDs in var.all_network_acl_ids. We should be able to compute this automatically, but due to a Terraform limitation, we can't: https://github.com/hashicorp/terraform/issues/14677#issuecomment-302772685"
}

variable "egress_starting_rule_number" {
  description = "The starting rule number for adding egress rules to the Network ACLs in var.network_acl_ids_with_external_vpc_access. This is used to ensure we don't add rules to those ACLs with numbers that conflict with existing rules."
}

variable "ingress_starting_rule_number" {
  description = "The starting rule number for adding ingress rules to the Network ACLs in var.network_acl_ids_with_external_vpc_access. This is used to ensure we don't add rules to those ACLs with numbers that conflict with existing rules."
}

variable "ingress_high_starting_rule_number" {
  description = "The starting rule number for adding the global DENY ingress rules to the Network ACLs in var.all_network_acl_ids. This should be a high number (always higher than var.ingress_starting_rule_number) to ensure rules that explicitly allow inbound connections from the external VPC take precedence."
}

variable "egress_high_starting_rule_number" {
  description = "The starting rule number for adding the global DENY egress rules to the Network ACLs in var.all_network_acl_ids. This should be a high number (always higher than var.egress_starting_rule_number) to ensure rules that explicitly allow outbound connections to the external VPC take precedence."
}

# ---------------------------------------------------------------------------------------------------------------------
# DEFINE CONSTANTS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

# See http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_ACLs.html#VPC_ACLs_Ephemeral_Ports
variable "ephemeral_from_port" {
  description = "Return traffic will be allowed on all ports between var.ephemeral_from_port and var.ephemeral_to_port, inclusive, from var.external_vpc_cidr_block"
  default     = 1024
}

# See http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_ACLs.html#VPC_ACLs_Ephemeral_Ports
variable "ephemeral_to_port" {
  description = "Return traffic will be allowed on all ports between var.ephemeral_from_port and var.ephemeral_to_port, inclusive, from var.external_vpc_cidr_block"
  default     = 65535
}
