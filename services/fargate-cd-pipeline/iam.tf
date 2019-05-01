##################################
# Codepipeline Role
##################################

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
    aws_s3_bucket_source_arn = "${aws_s3_bucket.source.arn}"
    aws_s3_bucket_deploy_arn = "${aws_s3_bucket.deploy.arn}"
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline-policy-${var.service_name}-${var.env_name}"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = "${data.template_file.codepipeline_policy.rendered}"
}

##################################
# Codebuild Role
##################################
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
    aws_s3_bucket_arn = "${aws_s3_bucket.source.arn}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild-policy-${var.service_name}-${var.env_name}"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.template_file.codebuild_policy.rendered}"
}

#######################################
# ECS Service Scheduler Role
#######################################

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs-service-role-policy-${var.service_name}-${var.env_name}"
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

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-task-execution-role-${var.service_name}-${var.env_name}"

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

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name = "ecs-execution-role-policy-${var.service_name}-${var.env_name}"
  role = "${aws_iam_role.ecs_execution_role.id}"

  policy = "${file("${path.module}/files/ecs-execution-role-policy.json")}"
}

# ---------------------------------------------------
# S3 Bucket policies for var.allowed_s3_buckets from fargate app
# ---------------------------------------------------

resource "aws_iam_role_policy" "ecs_service_s3_access_role_policy" {
  count = "${signum(length(var.allowed_s3_buckets))}"
  name   = "ecs-service-s3-access-role-policy-${var.service_name}-${var.env_name}"
  role   = "${aws_iam_role.ecs_execution_role.id}"
  policy = "${data.aws_iam_policy_document.ecs_allow_s3_access_policy.json}"
}

data "aws_iam_policy_document" "ecs_allow_s3_access_policy" {
  count = "${length(var.allowed_s3_buckets)}"

  statement {
    effect = "Allow"

    //resources = ["*"]
    resources = ["${element(var.allowed_s3_buckets, count.index)}", "${element(var.allowed_s3_buckets, count.index)}/*"]

    //resources = "${element(var.var.allowed_s3_buckets, count.index)}"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:List*",
      "s3:PutObject",
    ]
  }
}
