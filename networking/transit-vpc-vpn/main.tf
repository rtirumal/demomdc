
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

data "terraform_remote_state" "account" {
  backend = "s3"

  config {
    region = "${var.account_terraform_state_aws_region}"
    bucket = "${var.account_terraform_state_s3_bucket}"
    key    = "${var.account_terraform_state_s3_key}/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.vpc_terraform_state_aws_region}"
    bucket = "${var.vpc_terraform_state_s3_bucket}"
    key    = "${var.vpc_terraform_state_s3_key}/terraform.tfstate"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# PARAMETER STORE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_ssm_parameter" "virginia_preshared_key1" {
  name            = "/${var.vpc_name}/vpn/virginia/preshared_key_1"
 type      = "SecureString"
 value     = "placeholder"
 overwrite = false

 lifecycle {
   ignore_changes  = ["overwrite","value"]
 }
 
 tags {
   VPC = "${var.vpc_name}"
 }
}

resource "aws_ssm_parameter" "virginia_preshared_key2" {
 name            = "/${var.vpc_name}/vpn/virginia/preshared_key_2"
 type      = "SecureString"
 value     = "placeholder"
 overwrite = false

 lifecycle {
   ignore_changes  = ["overwrite","value"]
 }
 
 tags {
   VPC = "${var.vpc_name}"
 }
}


resource "aws_ssm_parameter" "dublin_preshared_key1" {
  name            = "/${var.vpc_name}/vpn/dublin/preshared_key_1"
 type      = "SecureString"
 value     = "placeholder"
 overwrite = false

 lifecycle {
   ignore_changes  = ["overwrite","value"]
 }
 
 tags {
   VPC = "${var.vpc_name}"
 }
}

resource "aws_ssm_parameter" "dublin_preshared_key2" {
 name            = "/${var.vpc_name}/vpn/dublin/preshared_key_2"
 type      = "SecureString"
 value     = "placeholder"
 overwrite = false

 lifecycle {
   ignore_changes  = ["overwrite","value"]
 }
 
 tags {
   VPC = "${var.vpc_name}"
 }
}
# ---------------------------------------------------------------------------------------------------------------------
# DATA
# ---------------------------------------------------------------------------------------------------------------------
data "aws_ssm_parameter" "virginia_preshared_key1" {
  name            = "/${var.vpc_name}/vpn/virginia/preshared_key_1"
  with_decryption = true
  depends_on = ["aws_ssm_parameter.virginia_preshared_key1"]
}

data "aws_ssm_parameter" "virginia_preshared_key2" {
  name            = "/${var.vpc_name}/vpn/virginia/preshared_key_2"
  with_decryption = true
    depends_on = ["aws_ssm_parameter.virginia_preshared_key2"]
}

data "aws_ssm_parameter" "dublin_preshared_key1" {
  name            = "/${var.vpc_name}/vpn/dublin/preshared_key_1"
  with_decryption = true
    depends_on = ["aws_ssm_parameter.dublin_preshared_key1"]
}

data "aws_ssm_parameter" "dublin_preshared_key2" {
  name            = "/${var.vpc_name}/vpn/dublin/preshared_key_2"
  with_decryption = true
    depends_on = ["aws_ssm_parameter.dublin_preshared_key2"]
}
# ---------------------------------------------------------------------------------------------------------------------
# VPN GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpn_gateway" "this" {
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  tags = {
    Name = "${var.vpc_name}-and-transit-vpc"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# VPN CONNECTION
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_vpn_connection" "virginia" {
  vpn_gateway_id      = "${aws_vpn_gateway.this.id}"
  customer_gateway_id = "${data.terraform_remote_state.account.cgw_virginia_transitvpc_id}"
  type                = "${var.vpn_type_virginia}"
  static_routes_only  = "false"
  tunnel1_inside_cidr = "${var.virginia_tunnel_inside_cidr_1}"
  tunnel1_preshared_key = "${data.aws_ssm_parameter.virginia_preshared_key1.value}"
  tunnel2_inside_cidr = "${var.virginia_tunnel_inside_cidr_2}"
  tunnel2_preshared_key = "${data.aws_ssm_parameter.virginia_preshared_key2.value}"
    
  lifecycle {
    ignore_changes = [
      "tunnel1_preshared_key", 
      "tunnel2_preshared_key"
    ]
  }

  tags = { 
    Name = "${var.vpc_name}-and-virginia-transit-vpc"
    Terraform   = "true"
  }
}

resource "aws_vpn_connection" "dublin" {
  vpn_gateway_id      = "${aws_vpn_gateway.this.id}"
  customer_gateway_id = "${data.terraform_remote_state.account.cgw_dublin_transitvpc_id}"
  type                = "${var.vpn_type_dublin}"
  static_routes_only  = "false"
  tunnel1_inside_cidr = "${var.dublin_tunnel_inside_cidr_1}"
  tunnel1_preshared_key = "${data.aws_ssm_parameter.dublin_preshared_key1.value}"
  tunnel2_inside_cidr = "${var.dublin_tunnel_inside_cidr_2}"
  tunnel2_preshared_key = "${data.aws_ssm_parameter.dublin_preshared_key2.value}"

  lifecycle {
    ignore_changes = [
      "tunnel1_preshared_key", 
      "tunnel2_preshared_key"
    ]
  }

  tags = { 
    Name = "${var.vpc_name}-and-dublin-transit-vpc"
    Terraform   = "true"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE PROPAGATION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpn_gateway_route_propagation" "transit_vpc_vgw" {
  vpn_gateway_id = "${aws_vpn_gateway.this.id}"
  route_table_id = "${element(var.private_route_table_list, count.index)}"
  count          = "${length(var.private_route_table_list)}"
}
