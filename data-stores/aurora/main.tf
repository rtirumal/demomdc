# --------------------------------------------------------------------------------
# AWS Aurora Database Package
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# --------------------------------------------------------------------------------
provider "aws" {
  # The AWS region in which all resources will be created
  region = "${var.aws_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${var.aws_account_id}"]
}

# --------------------------------------------------------------------------------
# CONFIGURE REMOTE STATE STORAGE
# --------------------------------------------------------------------------------
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # Only allow this Terraform version. Note that if you upgrade to a newer version, Terraform won't allow you to use an
  # older version, so when you upgrade, you should upgrade everyone on your team and your CI servers all at once. 
  # Hint: Use tfenv
  required_version = "~> 0.11.10"
}

# --------------------------------------------------------------------------------
# Add DataLookup for VPC
# --------------------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

data "aws_ssm_parameter" "master_password" {
  name = "${aws_ssm_parameter.ssm_aurora_postgres_master_password.name}"
  depends_on = ["aws_ssm_parameter.ssm_aurora_postgres_master_password"]
}
 
# --------------------------------------------------------------------------------
# LOCAL VARIABLES
# --------------------------------------------------------------------------------
locals {
  component_name = "${var.service_name}-${var.component_name}"
}

# --------------------------------------------------------------------------------
# Aurora DB
# --------------------------------------------------------------------------------
module "aurora" {
  source = "git::git@github.com:gruntwork-io/module-data-storage.git//modules/aurora?ref=v0.8.7"

  # Get vpc_id from the data lookup along with subnet_ids and CIDR blocks
  vpc_id                             = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_ids                         = ["${data.terraform_remote_state.vpc.private_persistence_subnet_ids}"]
  allow_connections_from_cidr_blocks = "${concat(var.allow_connections_from_cidr_blocks, data.terraform_remote_state.vpc.private_app_subnet_cidr_blocks)}"

  name            = "${var.name}"
  db_name         = "${var.db_name}"
  master_username = "${var.master_username}"
  master_password = "${data.aws_ssm_parameter.master_password.value}"
  instance_count  = "${var.instance_count}"
  instance_type   = "${var.instance_type}"

  monitoring_interval = "${var.monitoring_interval}"
  monitoring_role_arn = "${var.monitoring_role_arn}"

  port                                   = "${var.port}"
  backup_retention_period                = "${var.backup_retention_period}"
  preferred_backup_window                = "${var.preferred_backup_window}"
  preferred_maintenance_window           = "${var.preferred_maintenance_window}"
  apply_immediately                      = "${var.apply_immediately}"
  storage_encrypted                      = "${var.storage_encrypted}"
  kms_key_arn                            = "${var.kms_key_arn}"
  allow_connections_from_security_groups = "${var.allow_connections_from_security_groups}"
  iam_database_authentication_enabled    = "${var.iam_database_authentication_enabled}"

  snapshot_identifier              = "${var.snapshot_identifier}"
  engine                           = "${var.engine}"
  engine_version                   = "${var.engine_version}"
  db_cluster_parameter_group_name  = "${var.db_cluster_parameter_group_name}"
  db_instance_parameter_group_name = "${var.db_instance_parameter_group_name}"

  custom_tags = "${var.custom_tags}"
}

resource "random_string" "generated_password" {
  length = 16
  special = true
  min_special = 1
  min_upper = 2
  min_lower = 3
  min_numeric = 5
}

resource "aws_ssm_parameter" "ssm_aurora_postgres_master_username" {
  name  = "/${local.component_name}/${var.service_environment}/postgresql/master-username"
  type  = "SecureString"
  value = "${var.master_username}"
  key_id = "${var.kms_key_arn}"
}

resource "aws_ssm_parameter" "ssm_aurora_postgres_master_password" {
  name  = "/${local.component_name}/${var.service_environment}/postgresql/master-password"
  type  = "SecureString"
  value = "${random_string.generated_password.result}"
  key_id = "${var.kms_key_arn}"
}

resource "aws_ssm_parameter" "ssm_aurora_postgres_database_name" {
  name  = "/${local.component_name}/${var.service_environment}/postgresql/database-name"
  type  = "SecureString"
  value = "${module.aurora.db_name}"
  key_id = "${var.kms_key_arn}"
}

resource "aws_ssm_parameter" "ssm_aurora_postgres_cluster_endpoint" {
  name  = "/${local.component_name}/${var.service_environment}/postgresql/cluster-endpoint"
  type  = "SecureString"
  value = "${module.aurora.cluster_endpoint}"
  key_id = "${var.kms_key_arn}"
}

resource "aws_ssm_parameter" "ssm_aurora_postgres_reader_endpoint" {
  name  = "/${local.component_name}/${var.service_environment}/postgresql/reader-endpoint"
  type  = "SecureString"
  value = "${module.aurora.reader_endpoint}"
  key_id = "${var.kms_key_arn}"
}

resource "aws_ssm_parameter" "ssm_aurora_postgres_cluster_port" {
  name  = "/${local.component_name}/${var.service_environment}/postgresql/cluster-port"
  type  = "SecureString"
  value = "${module.aurora.port}"
  key_id = "${var.kms_key_arn}"
}
