# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY JENKINS
# This module can be used to run a Jenkins server. It creates the following resources:
#
# - An ASG to run Jenkins
# - An EBS volume for Jenkins that persists between redeploys
# - A lambda function to periodically take a snapshot of the EBS volume
# - A CloudWatch alarm that goes off if a backup job fails to run
# - An ALB to route traffic to Jenkins
# - A Route 53 DNS A record pointing at the ALB
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
# LAUNCH JENKINS
# ---------------------------------------------------------------------------------------------------------------------

module "jenkins" {
  source = "git::git@github.com:gruntwork-io/module-ci.git//modules/jenkins-server?ref=v0.13.3"

  name             = "${var.name}"
  aws_region       = "${var.aws_region}"
  aws_account_id   = "${var.aws_account_id}"
  environment_name = "${var.vpc_name}"

  ami_id                    = "${var.ami}"
  instance_type             = "${var.instance_type}"
  user_data                 = "${data.template_file.user_data.rendered}"
  skip_health_check         = "${var.skip_health_check}"
  health_check_grace_period = "${var.health_check_grace_period}"

  vpc_id            = "${data.terraform_remote_state.mgmt.vpc_id}"
  jenkins_subnet_id = "${element(data.terraform_remote_state.mgmt.private_subnet_ids, 0)}"

  alb_subnet_ids = ["${data.terraform_remote_state.mgmt.public_subnet_ids}"]
  tenancy        = "${var.tenancy}"

  create_route53_entry = "${var.create_route53_entry}"
  hosted_zone_id       = "${var.hosted_zone_id}"
  domain_name          = "${var.domain_name}"
  acm_cert_domain_name = "${var.acm_ssl_certificate_domain}"

  allow_incoming_http_from_cidr_blocks = "${var.allow_incoming_http_from_cidr_blocks}"

  # Not sure how Adobe security will be set up going forward so comemnting these out for now and
  # just using the above option to set only the office IPs


  # allow_incoming_http_from_security_group_ids = ["${var.user_access_security_group_id}"]
  # allow_ssh_from_security_group_ids = ["${var.user_access_security_group_id}"]

  key_pair_name                         = "${var.keypair_name}"
  allow_ssh_from_cidr_blocks            = []
  root_block_device_volume_type         = "gp2"
  root_block_device_volume_size         = "${var.root_volume_size}"
  ebs_volume_type                       = "gp2"
  ebs_volume_size                       = "${var.jenkins_volume_size}"
  ebs_volume_encrypted                  = "${var.jenkins_volume_encrypted}"
  ebs_optimized                         = "${var.ebs_optimized}"
  num_days_after_which_archive_log_data = "${var.num_days_after_which_archive_log_data}"
  num_days_after_which_delete_log_data  = "${var.num_days_after_which_delete_log_data}"
  custom_tags                           = "${var.custom_tags}"
  is_internal_alb                       = "${var.is_internal_alb}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE USER DATA SCRIPT TO RUN ON JENKINS WHEN IT BOOTS
# This script will attach and mount the EBS volume
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data/user-data.sh")}"

  vars {
    aws_region = "${var.aws_region}"

    # This is the default name tag for the server-group module Jenkins uses under the hood
    volume_name_tag = "ebs-volume-0"

    device_name    = "${var.jenkins_device_name}"
    mount_point    = "${var.jenkins_mount_point}"
    owner          = "${var.jenkins_user}"
    memory         = "${var.memory}"
    vpc_name       = "${data.terraform_remote_state.mgmt.vpc_name}"
    log_group_name = "${var.name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE JENKINS THE PERMISSIONS IT NEEDS TO BUILD DOCKER IMAGES AND AMIS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "build_permissions" {
  name   = "${var.name}-build-permissions"
  policy = "${data.aws_iam_policy_document.build_permissions.json}"
}

data "aws_iam_policy_document" "build_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:*",
      "ecr:*",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy_attachment" "attach_build_permissions" {
  name       = "attach-build-permissions"
  roles      = ["${module.jenkins.jenkins_iam_role_id}"]
  policy_arn = "${aws_iam_policy.build_permissions.arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD IAM POLICY THAT ALLOWS READING AND WRITING CLOUDWATCH METRICS
# ---------------------------------------------------------------------------------------------------------------------

module "cloudwatch_metrics" {
  source      = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/metrics/cloudwatch-custom-metrics-iam-policy?ref=v0.10.0"
  name_prefix = "${var.name}"
}

resource "aws_iam_policy_attachment" "attach_cloudwatch_metrics_policy" {
  name       = "attach-cloudwatch-metrics-policy"
  roles      = ["${module.jenkins.jenkins_iam_role_id}"]
  policy_arn = "${module.cloudwatch_metrics.cloudwatch_metrics_policy_arn}"
}

# ------------------------------------------------------------------------------
# ADD IAM POLICY THAT ALLOWS CLOUDWATCH LOG AGGREGATION
# ------------------------------------------------------------------------------

module "cloudwatch_log_aggregation" {
  source      = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/logs/cloudwatch-log-aggregation-iam-policy?ref=v0.10.0"
  name_prefix = "${var.name}"
}

resource "aws_iam_policy_attachment" "attach_cloudwatch_log_aggregation_policy" {
  name       = "attach-cloudwatch-log-aggregation-policy"
  roles      = ["${module.jenkins.jenkins_iam_role_id}"]
  policy_arn = "${module.cloudwatch_log_aggregation.cloudwatch_log_aggregation_policy_arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD CLOUDWATCH ALARMS THAT GO OFF IF JENKIN'S CPU, MEMORY, OR DISK USAGE GET TOO HIGH
# ---------------------------------------------------------------------------------------------------------------------

module "high_cpu_usage_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/asg-cpu-alarms?ref=v0.10.0"
  asg_names            = ["${module.jenkins.jenkins_asg_name}"]
  num_asg_names        = 1
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}

module "high_memory_usage_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/asg-memory-alarms?ref=v0.10.0"
  asg_names            = ["${module.jenkins.jenkins_asg_name}"]
  num_asg_names        = 1
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}

module "high_disk_usage_jenkins_volume_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/asg-disk-alarms?ref=v0.10.0"
  asg_names            = ["${module.jenkins.jenkins_asg_name}"]
  num_asg_names        = 1
  file_system          = "${var.jenkins_device_name}"
  mount_path           = "${var.jenkins_mount_point}"
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}

module "high_disk_usage_root_volume_alarms" {
  source               = "git::git@github.com:gruntwork-io/module-aws-monitoring.git//modules/alarms/asg-disk-alarms?ref=v0.10.0"
  asg_names            = ["${module.jenkins.jenkins_asg_name}"]
  num_asg_names        = 1
  file_system          = "/dev/xvda1"
  mount_path           = "/"
  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# RUN A SCHEDULED LAMBDA FUNCTION TO PERIODICALLY BACK UP THE JENKINS SERVER
# The lambda function uses a tool called ec2-snapper to take a snapshot of the Jenkins EBS volume
# ---------------------------------------------------------------------------------------------------------------------

module "jenkins_backup" {
  source = "git::git@github.com:gruntwork-io/module-ci.git//modules/ec2-backup?ref=v0.13.3"

  instance_name = "${module.jenkins.jenkins_asg_name}"

  backup_job_schedule_expression = "${var.backup_schedule_expression}"
  backup_job_alarm_period        = "${var.backup_job_alarm_period}"

  delete_older_than = "15d"
  require_at_least  = 15

  cloudwatch_metric_name      = "${var.backup_job_metric_namespace}"
  cloudwatch_metric_namespace = "${var.backup_job_metric_name}"

  alarm_sns_topic_arns = ["${data.terraform_remote_state.sns_region.arn}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# PULL MGMT VPC DATA FROM THE TERRAFORM REMOTE STATE
# These templates run on top of the VPCs created by the VPC templates, which store their Terraform state files in an S3
# bucket using remote state storage.
# ---------------------------------------------------------------------------------------------------------------------

data "terraform_remote_state" "mgmt" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/mgmt/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "sns_region" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/_global/sns-topics/terraform.tfstate"
  }
}
