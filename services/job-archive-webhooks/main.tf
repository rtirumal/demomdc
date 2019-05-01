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

locals {
  component_name = "${var.service_name}-webhooks"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE SQS QUEUE
# ---------------------------------------------------------------------------------------------------------------------
module "sqs" {
  source                      = "git::git@github.com:gruntwork-io/package-messaging.git//modules/sqs?ref=v0.1.3"
  name                        = "${local.component_name}-${var.service_environment}-queue"
  visibility_timeout_seconds  = "${var.visibility_timeout_seconds}"
  message_retention_seconds   = "${var.message_retention_seconds}"
  max_message_size            = "${var.max_message_size}"
  delay_seconds               = "${var.delay_seconds}"
  receive_wait_time_seconds   = "${var.receive_wait_time_seconds}"
  fifo_queue                  = false
  dead_letter_queue           = true
  max_receive_count           = "${var.max_receive_count}"
  custom_tags                 = "${var.custom_tags}"
}

resource "aws_sns_topic_subscription" "sns_completed_tasks_sqs_subscription" {
  topic_arn = "${data.terraform_remote_state.job_archive_control.sns_completed_tasks_arn}"
  protocol  = "sqs"
  endpoint  = "${module.sqs.queue_arn}"
  raw_message_delivery = "true"
}

# --------------------------------------------------------------------------------
# CREATE A SECURITY GROUP
# --------------------------------------------------------------------------------
resource "aws_security_group" "job_archive_webhooks" {
  name        = "${local.component_name}-${var.service_environment}-sg"
  description = "Job Archive Webhooks ${var.service_environment} lambda security group"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  tags        = "${merge(map("Name", format("%s-%s",local.component_name, var.service_environment)), var.custom_tags)}"
}

# --------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP RULE
# --------------------------------------------------------------------------------
resource "aws_security_group_rule" "allow_5432_egress_connections" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["${data.terraform_remote_state.vpc.private_persistence_subnet_cidr_blocks}"]
  security_group_id = "${aws_security_group.job_archive_webhooks.id}"
  description       = "Allow all tcp 5432 egress to Postgres RDS"
}

resource "aws_security_group_rule" "allow_https_egress_connections" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.job_archive_webhooks.id}"
  description       = "Allow all tcp 443 egress to SQS"
}
