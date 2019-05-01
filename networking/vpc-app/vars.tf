# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
}

variable "vpc_name" {
  description = "Name of the VPC. Examples include 'prod', 'dev', 'mgmt', etc."
}

variable "cidr_block" {
  description = "The IP address range of the VPC in CIDR notation. A prefix of /18 is recommended. Do not use a prefix higher than /27. Examples include '10.100.0.0/18', '10.200.0.0/18', etc."
}

variable "num_nat_gateways" {
  description = "The number of NAT Gateways to launch for this VPC. For production VPCs, a NAT Gateway should be placed in each Availability Zone (so likely 3 total), whereas for non-prod VPCs, just one Availability Zone (and hence 1 NAT Gateway) will suffice."
}

variable "num_availability_zones" {
  description = "How many AWS Availability Zones (AZs) to use. One subnet of each type (public, private app, private persistence) will be created in each AZ. Note that this must be less than or equal to the total number of AZs in a region. A value of -1 means all AZs should be used. For example, if you specify 3 in a region with 5 AZs, subnets will be created in just 3 AZs instead of all 5."
  default     = "-1"
}

variable "tenancy" {
  description = "The allowed tenancy of instances launched into the selected VPC. Must be one of: default, dedicated, or host."
  default     = "default"
}

variable "allow_private_persistence_internet_access" {
  description = "Should the private persistence subnet be allowed outbound access to the internet?"
  default     = false
}

variable "custom_tags" {
  description = "A map of tags to apply to the VPC, Subnets, Route Tables, and Internet Gateway, and VPC endpoint security groups. The key is the tag name and the value is the tag value. Note that the tag 'Name' is automatically added by this module but may be optionally overwritten by this variable."
  type        = "map"
  default     = {}
}

variable "subnet_spacing" {
  description = "The amount of spacing between the different subnet types"
  default     = 10
}

# ---------------------------------------------------------------------------------------------------------------------
# API Gateway Interface Endpoint
# ---------------------------------------------------------------------------------------------------------------------

variable "api_gateway_interface_ports_ingress_list" {
  description = "List of ingress ports to allow from VPC CIDR range"
  default     = []
}

variable "api_gateway_interface_ports_egress_list" {
  description = "List of Egress ports to allow egress to 0.0.0.0/0"
  default     = []
}
