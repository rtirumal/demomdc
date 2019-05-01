# ---------------------------------------------------------------------------------------------------------------------
# CODEPIPELINE ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role-${var.service_name}-${var.env_name}-deploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
    EOF
}

data "template_file" "codepipeline_policy" {
  template = "${file("${path.module}/files/codepipeline.json")}"

  vars {
    aws_s3_bucket_source_arn                   = "${aws_s3_bucket.source.arn}"
    aws_s3_bucket_deploy_arn                   = "${aws_s3_bucket.deploy.arn}"
    aws_s3_bucket_placeholder_arn              = "${data.terraform_remote_state.acct_level_resources.placeholder_bucket_arn}"
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline-policy-${var.service_name}-${var.env_name}"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = "${data.template_file.codepipeline_policy.rendered}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CODEBUILD ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-${var.service_name}-${var.env_name}-deploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
 EOF
}

data "template_file" "codebuild_policy" {
  template = "${file("${path.module}/files/codebuild_policy.json")}"

  vars {
    aws_s3_bucket_arn                   = "${aws_s3_bucket.source.arn}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild-policy-${var.service_name}-${var.env_name}"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.template_file.codebuild_policy.rendered}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS SERVICE SCHEDULER ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs-service-role-policy-${var.service_name}-${var.service_role}-${var.env_name}"
  role   = "${aws_iam_role.ecs_execution_role.id}"
  policy = "${data.aws_iam_policy_document.ecs_service_policy.json}"
}

data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "ec2:Describe*",
      "ec2:AuthorizeSecurityGroupIngress",
      "ssm:DescribeParameters",
      "ssm:GetParameters",
      "kms:Decrypt",
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS EXECUTION ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-task-execution-role-${var.service_name}-${var.service_role}-${var.env_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

data "template_file" "ecs_execution_role_policy" {
  template = "${file("${path.module}/files/ecs-execution-role-policy.json")}"

  vars {
    aws_region =        "${var.aws_region}"
    aws_account_id = "${var.aws_account_id}"
    service_name = "${var.service_name}"
    env_name = "${var.env_name}"
    aws_s3_jenkins_artifacts_arn = "${aws_s3_bucket.jenkins_artifacts.arn}"
    aws_s3_jenkins_build_packages_arn = "${aws_s3_bucket.jenkins_build_packages.arn}"
  }
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name = "ecs-execution-role-policy-${var.service_name}-${var.service_role}-${var.env_name}"
  role = "${aws_iam_role.ecs_execution_role.id}"

  policy = "${data.template_file.ecs_execution_role_policy.rendered}"
}

# ---------------------------------------------------------------------------------------------------------------------
# JENKINS ECS ROLE 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "jenkins_ecs_role" {
  name = "jenkins-ecs-role-${var.service_name}-${var.env_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
    EOF
}

data "template_file" "jenkins_ecs_policy" {
  template = "${file("${path.module}/files/jenkins-ecs-policy.json")}"

  vars {
    aws_region                  = "${var.aws_region}"
    aws_account_id                  = "${var.aws_account_id}"
    cluster_name = "${module.cluster_master.cluster_arn}"
    aws_s3_jenkins_artifacts_arn = "${aws_s3_bucket.jenkins_artifacts.arn}"
    aws_s3_jenkins_build_packages_arn = "${aws_s3_bucket.jenkins_build_packages.arn}"
  }
}

resource "aws_iam_role_policy" "jenkins_ecs_policy" {
  name = "jenkins-ecs-policy-${var.service_name}-${var.env_name}"
  role = "${aws_iam_role.jenkins_ecs_role.id}"

  policy = "${data.template_file.jenkins_ecs_policy.rendered}"
}
