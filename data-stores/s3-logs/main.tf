# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# S3 Log Bucket Package - log, artifact, object storage with lifecycle management
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
  required_version = "~>0.11.10"
}

# --------------------------------------
# S3 Bucket
# --------------------------------------

module "bucket" {
  source = "git::git@github.com:magento/tf-aws-s3-logs.git?ref=v1.2"

  aws_region = "${var.aws_region}"

  # Input cleanup. Name must be lowercase letters, numbers, and hyphens. For the full rules, see:
  # http://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html#bucketnamingrules
  bucket_name = "${lower(replace(var.bucket_name, "_", "-"))}"

  acl    = "${var.acl}"
  policy = "${var.policy}"

  lifecycle_rule_enabled   = "${var.lifecycle_rule_enabled}"
  prefix                   = "${var.prefix}"
  standard_transition_days = "${var.standard_transition_days}"
  glacier_transition_days  = "${var.glacier_transition_days}"
  expiration_days          = "${var.expiration_days}"

  versioning_enabled                          = "${var.versioning_enabled}"
  noncurrent_version_standard_transition_days = "${var.noncurrent_version_standard_transition_days}"
  noncurrent_version_glacier_transition_days  = "${var.noncurrent_version_glacier_transition_days}"
  noncurrent_version_expiration_days          = "${var.noncurrent_version_expiration_days}"

  tags = "${var.tags}"

  force_destroy = "${var.force_destroy}"
}
