# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
  version = "~> 1.52.0"
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
  required_version = "= 0.11.10"
}


# ---------------------------------------------------------------------------------------------------------------------
# DATA
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ssm_parameter" "datadog_api_key" {
  name            = "/${var.vpc_name}/${var.service_name}/datadog/apikey"
  with_decryption = true
}

data "aws_ssm_parameter" "master_ecr_repo" {
  name            = "/${var.service_name}/master/ecr-repo-url"
  with_decryption = false
}

data "aws_ssm_parameter" "jenkins_aws_access_key" {
  name            = "/${var.service_name}/${var.env_name}/jenkins/aws-access-key"
  with_decryption = true
  depends_on        = ["aws_ssm_parameter.testing_service_jenkins_aws_access_key"]

}

data "aws_ssm_parameter" "jenkins_aws_secret_key" {
  name            = "/${var.service_name}/${var.env_name}/jenkins/aws-secret-key"
  with_decryption = true
  depends_on        = ["aws_ssm_parameter.testing_service_jenkins_aws_secret_key"]

}

data "terraform_remote_state" "acct_level_resources" {
 backend = "s3"

 config {
   region = "${var.acct_level_resources_region}"
   bucket = "${var.acct_level_resources_s3_bucket}"
   key    = "${var.acct_level_resources_s3_key}/terraform.tfstate"
 }
}

data "terraform_remote_state" "sg_office_access" {
  backend = "s3"

  config {
    region = "${var.sg_office_access_terraform_state_aws_region}"
    bucket = "${var.sg_office_access_terraform_state_s3_bucket}"
    key    = "${var.sg_office_access_terraform_state_s3_key}/terraform.tfstate"
  }
}