# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A MGMT VPC
# This is a VPC for DevOps tooling (e.g. Jenkins, Bastion Host).
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
  required_version = "= 0.11.8"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE VPC
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "git::git@github.com:gruntwork-io/module-vpc.git//modules/vpc-mgmt?ref=v0.5.1"

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

  # The amount of spacing between the different subnet types
  subnet_spacing = "${var.subnet_spacing}"

  # Some teams may want to explicitly define the exact CIDR blocks used by their subnets. See the documentation in the
  # module source code. We haven't implemented those variables here. 

  # A map of tags to apply to the VPC, Subnets, Route Tables, and Internet Gateway. Note that the tag 'Name' is 
  # automatically added by this module but may be optionally overwritten by this variable.
  custom_tags = "${var.custom_tags}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE NETWORK ACLS FOR THE MGMT VPC
# Network ACLs provide an extra layer of network security across an entire subnet, whereas security groups provide
# network security on a single resource.
# ---------------------------------------------------------------------------------------------------------------------

module "vpc_network_acls" {
  source = "git::git@github.com:gruntwork-io/module-vpc.git//modules/vpc-mgmt-network-acls?ref=v0.5.1"

  vpc_id      = "${module.vpc.vpc_id}"
  vpc_name    = "${module.vpc.vpc_name}"
  vpc_ready   = "${module.vpc.vpc_ready}"
  num_subnets = "${module.vpc.num_availability_zones}"

  public_subnet_ids  = "${module.vpc.public_subnet_ids}"
  private_subnet_ids = "${module.vpc.private_subnet_ids}"

  public_subnet_cidr_blocks  = "${module.vpc.public_subnet_cidr_blocks}"
  private_subnet_cidr_blocks = "${module.vpc.private_subnet_cidr_blocks}"
}
