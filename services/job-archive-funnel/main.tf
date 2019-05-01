# --------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# --------------------------------------------------------------------------------
provider "aws" {
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
  required_version = "~> 0.11.10"
}

# --------------------------------------------------------------------------------
# PULL APP VPC DATA FROM THE TERRAFORM REMOTE STATE
# --------------------------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "job_archive_control" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/job-archive-control/terraform.tfstate"
  }
}

# --------------------------------------------------------------------------------
# LOCAL VARIABLES
# --------------------------------------------------------------------------------
locals {
  legacy_environment = "${var.service_environment == "prod" ? "prod" : "int"}"
  component_name     = "${var.service_name}-funnel"
}

# --------------------------------------------------------------------------------
# KMS Master Key for encrypting SSM parameters
# --------------------------------------------------------------------------------
module "kms_master_key" {
  source = "git::git@github.com:gruntwork-io/module-security.git//modules/kms-master-key?ref=v0.15.4"

  aws_account_id                        = "${var.aws_account_id}"
  name                                  = "${local.component_name}-${var.service_environment}-kms-key"
  cmk_administrator_iam_arns            = "${var.cmk_administrator_iam_arns}"
  cmk_user_iam_arns                     = "${concat(var.cmk_user_iam_arns, list(aws_iam_role.iam_role_funnel_lambda.arn))}"
  allow_manage_key_permissions_with_iam = "false"
}

# --------------------------------------------------------------------------------
# SQS Queue for all complete tasks
# --------------------------------------------------------------------------------
module "sqs_completed_tasks" {
  source = "git::git@github.com:gruntwork-io/package-messaging.git//modules/sqs?ref=v0.1.1"

  name                       = "${local.component_name}-${var.service_environment}-sqs-completed-tasks"
  dead_letter_queue          = true
  visibility_timeout_seconds = "${var.sqs_completed_tasks_visibility_timeout_seconds}"
  max_receive_count          = "${var.sqs_completed_tasks_max_receive_count}"
}

resource "aws_sns_topic_subscription" "sns_completed_tasks_sqs_subscription" {
  topic_arn            = "${data.terraform_remote_state.job_archive_control.sns_completed_tasks_arn}"
  protocol             = "sqs"
  endpoint             = "${module.sqs_completed_tasks.queue_arn}"
  raw_message_delivery = "true"
}

resource "aws_ssm_parameter" "ssm_sqs_completed_tasks_url" {
  name   = "/${local.component_name}/${var.service_environment}/sqs/completed-tasks/url"
  type   = "SecureString"
  value  = "${module.sqs_completed_tasks.queue_url}"
  key_id = "${module.kms_master_key.key_id}"
}

# --------------------------------------------------------------------------------
# Create SQS Queue for processing test results
# --------------------------------------------------------------------------------
module "sqs_unprocessed_tests" {
  source = "git::git@github.com:gruntwork-io/package-messaging.git//modules/sqs?ref=v0.1.1"

  name                       = "${local.component_name}-${var.service_environment}-sqs-unprocessed-tests"
  dead_letter_queue          = true
  visibility_timeout_seconds = 120
  max_receive_count          = 3
}

resource "aws_ssm_parameter" "ssm_sqs_unprocessed_tests_name" {
  name   = "/${local.component_name}/${var.service_environment}/sqs/unprocessed-tests/name"
  type   = "SecureString"
  value  = "${module.sqs_unprocessed_tests.queue_name}"
  key_id = "${module.kms_master_key.key_id}"
}

resource "aws_ssm_parameter" "ssm_sqs_unprocessed_tests_url" {
  name   = "/${local.component_name}/${var.service_environment}/sqs/unprocessed-tests/url"
  type   = "SecureString"
  value  = "${module.sqs_unprocessed_tests.queue_url}"
  key_id = "${module.kms_master_key.key_id}"
}

# --------------------------------------------------------------------------------
# S3 Bucket for storing Unprocessed Test JSON
# --------------------------------------------------------------------------------
module "s3_raw_test_data" {
  source = "git::git@github.com:magento/tf-aws-s3-logs.git?ref=v1.2"

  bucket_name              = "${local.component_name}-${var.service_environment}-s3-raw-test-data"
  acl                      = "private"
  policy                   = ""
  aws_region               = "us-east-1"
  force_destroy            = true
  lifecycle_rule_enabled   = true
  versioning_enabled       = false
  prefix                   = ""
  standard_transition_days = 30
  glacier_transition_days  = 60
  expiration_days          = 0
}

resource "aws_ssm_parameter" "ssm_s3_raw_test_data_name" {
  name   = "/${local.component_name}/${var.service_environment}/s3/raw-test-data/name"
  type   = "SecureString"
  value  = "${module.s3_raw_test_data.bucket_id}"
  key_id = "${module.kms_master_key.key_id}"
}

resource "aws_ssm_parameter" "ssm_s3_task_artifacts_name" {
  name   = "/${local.component_name}/${var.service_environment}/s3/task-artifacts/name"
  type   = "SecureString"
  value  = "buildarchive-${local.legacy_environment}-artifacts"
  key_id = "${module.kms_master_key.key_id}"
}

# --------------------------------------------------------------------------------
# SECURITY
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# SECURITY GROUP
# --------------------------------------------------------------------------------
resource "aws_security_group" "job_archive_funnel" {
  name        = "${local.component_name}-${var.service_environment}-sg"
  description = "Job Archive Funnel ${var.service_environment} lambda security group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(map("Name", format("%s-%s",local.component_name, var.service_environment)), var.custom_tags)}"
}

# --------------------------------------------------------------------------------
# SECURITY GROUP RULES
# --------------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_5432_egress_connections" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.private_persistence_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.job_archive_funnel.id}"
  description       = "Allow all tcp 5432 egress to Postgres RDS"
}

resource "aws_security_group_rule" "allow_https_egress_connections" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.job_archive_funnel.id}"
  description       = "Allow all tcp 443 egress to SQS"
}

resource "aws_iam_role" "iam_role_funnel_lambda" {
  name = "${local.component_name}-${var.service_environment}-${var.aws_region}-lambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iam_role_funnel_lambda_vpc_access_policy" {
  role       = "${aws_iam_role.iam_role_funnel_lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "iam_role_funnel_lambda_inline_policy" {
  name = "${local.component_name}-${var.service_environment}-lambda"
  role = "${aws_iam_role.iam_role_funnel_lambda.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "logs:CreateLogStream"
          ],
          "Resource": [
              "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${local.component_name}-${var.service_environment}-validate:*",
              "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${local.component_name}-${var.service_environment}-process:*"
          ],
          "Effect": "Allow"
      },
      {
          "Action": [
              "logs:PutLogEvents"
          ],
          "Resource": [
              "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${local.component_name}-${var.service_environment}-validate:*:*",
              "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${local.component_name}-${var.service_environment}-process:*:*"
          ],
          "Effect": "Allow"
      },
      {
          "Action": [
              "ssm:GetParametersByPath"
          ],
          "Resource": [
              "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${local.component_name}/*",
              "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.service_name}-data/*",
              "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.service_name}-aurora/*"
          ],
          "Effect": "Allow"
      },
      {
          "Action": [
              "sqs:*"
          ],
          "Resource": [
              "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:*"
          ],
          "Effect": "Allow"
      },
      {
          "Action": [
              "kms:Decrypt"
          ],
          "Resource": [
              "arn:aws:kms:${var.aws_region}:${var.aws_account_id}:alias/${local.component_name}-${var.service_environment}-kms-key"
          ],
          "Effect": "Allow"
      },
      {
          "Action": [
              "s3:GetObject",
              "s3:ListBucket",
              "s3:PutObject"
          ],
          "Resource": [
              "arn:aws:s3:::buildarchive-${local.legacy_environment}-artifacts",
              "arn:aws:s3:::buildarchive-${local.legacy_environment}-artifacts/*",
              "arn:aws:s3:::${local.component_name}-${var.service_environment}-s3-raw-test-data",
              "arn:aws:s3:::${local.component_name}-${var.service_environment}-s3-raw-test-data/*"
          ],
          "Effect": "Allow"
      },
      {
          "Action": [
              "sqs:ReceiveMessage",
              "sqs:DeleteMessage",
              "sqs:GetQueueAttributes"
          ],
          "Resource": [
              "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:${local.component_name}-${var.service_environment}-sqs-completed-tasks"
          ],
          "Effect": "Allow"
      },
      {
          "Action": [
              "sqs:ReceiveMessage",
              "sqs:DeleteMessage",
              "sqs:GetQueueAttributes"
          ],
          "Resource": [
              "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:${local.component_name}-${var.service_environment}-sqs-unprocessed-tests"
          ],
          "Effect": "Allow"
      }
  ]
} 
EOF
}

resource "aws_ssm_parameter" "ssm_iam_role_funnel_lambda_name" {
  name   = "/${local.component_name}/${var.service_environment}/iam/lambda-role/name"
  type   = "SecureString"
  value  = "${aws_iam_role.iam_role_funnel_lambda.name}"
  key_id = "${module.kms_master_key.key_id}"
}

resource "aws_ssm_parameter" "ssm_iam_role_funnel_lambda_arn" {
  name   = "/${local.component_name}/${var.service_environment}/iam/lambda-role/arn"
  type   = "SecureString"
  value  = "${aws_iam_role.iam_role_funnel_lambda.arn}"
  key_id = "${module.kms_master_key.key_id}"
}
