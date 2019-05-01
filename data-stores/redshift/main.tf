# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# AWS Redshift Database Package
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
  # Hint: Use tfenv
  required_version = "~> 0.11"
}

# --------------
# Add DataLookup for VPC
# --------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

# --------------
# Create Bucket Policy
# --------------

# Get the account id of the RedShift service account in a given region for the
# purpose of allowing RedShift to store audit data in S3.
data "aws_redshift_service_account" "main" {}

# JSON template defining access to allow Redshift service to write logs to the bucket
data "template_file" "redshift_logs_policy" {
  template = "${file("${path.module}/policy.tpl")}"

  vars = {
    bucket                  = "${var.s3_log_bucket_name}"
    redshift_log_account_id = "${data.aws_redshift_service_account.main.id}"
    redshift_logs_prefix    = "${var.logging_s3_key_prefix}"
  }
}

# ------------
# S3 Bucket using bucket policy
# ------------

resource "aws_s3_bucket" "logs" {
  bucket = "${var.s3_log_bucket_name}"

  acl    = "log-delivery-write"
  region = "${var.aws_region}"
  policy = "${data.template_file.redshift_logs_policy.rendered}"

  lifecycle_rule {
    id      = "expire_all_logs"
    prefix  = "/*"
    enabled = true

    expiration {
      days = "${var.log_retention_in_days}"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${var.tags}"

  force_destroy = true
}

# ---------------
# Security group
# ---------------
resource "aws_security_group" "sg" {
  name        = "${var.name}-sg"
  description = "Allow redshift ingress and egress within VPC"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  #Ingress from its own VPC 
  ingress {
    from_port   = "${var.cluster_port}"
    to_port     = "${var.cluster_port}"
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.vpc.vpc_cidr_block}"]
  }

  #Egress to its own VPC 
  egress {
    from_port   = "${var.cluster_port}"
    to_port     = "${var.cluster_port}"
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.vpc.vpc_cidr_block}"]
  }
}

# -----------
# Redshift Cluster
# -----------
module "redshift" {
  source = "git::git@github.com:magento/tf-aws-redshift.git?ref=v0.1"

  cluster_identifier      = "${var.name}"
  cluster_version         = "${var.cluster_version}"
  cluster_node_type       = "${var.cluster_node_type}"
  cluster_number_of_nodes = "${var.cluster_number_of_nodes}"

  cluster_port = "${var.cluster_port}"

  cluster_iam_roles = "${var.cluster_iam_roles}"

  preferred_maintenance_window        = "${var.preferred_maintenance_window}"
  automated_snapshot_retention_period = "${var.automated_snapshot_retention_period}"

  wlm_json_configuration = "${var.wlm_json_configuration}"

  encrypted  = "${var.encrypted}"
  kms_key_id = "${var.kms_key_id}"

  allow_version_upgrade = "${var.allow_version_upgrade}"

  final_snapshot_identifier = "${var.final_snapshot_identifier}"
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  enable_logging            = true
  logging_bucket_name       = "${aws_s3_bucket.logs.id}"
  logging_s3_key_prefix     = "${var.logging_s3_key_prefix}"

  cluster_database_name   = "${var.cluster_database_name}"
  cluster_master_username = "${var.cluster_master_username}"
  cluster_master_password = "${var.cluster_master_password}"

  subnets                = ["${data.terraform_remote_state.vpc.private_persistence_subnet_ids}"]
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]

  tags = "${var.tags}"
}

