# ---------------------------------------------------------------------------------------------------------------------
# CODEBUILD DEPLOY
# ---------------------------------------------------------------------------------------------------------------------


data "template_file" "buildspec" {
  template = "${file("${path.module}/files/buildspec.yml")}"

  vars {
    vpc_name = "${var.vpc_name}"
    service_name = "${var.service_name}"
    service_role = "${var.service_role}"
    env_name = "${var.env_name}"
    repository_url = "${data.aws_ssm_parameter.master_ecr_repo.value}"
    aws_region = "${var.aws_region}"
  }
}
resource "aws_codebuild_project" "deploy" {
  name          = "${var.service_name}-${var.service_role}-${var.env_name}-deploy"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CODEBUILD DATA-WRITES
# ---------------------------------------------------------------------------------------------------------------------


data "template_file" "buildspec_data_writes" {
  template = "${file("${path.module}/files/buildspec-data-writes.yml")}"

  vars {
    current_deployed_param = "/${var.service_name}/${var.env_name}/currently-deployed"
  }
}
resource "aws_codebuild_project" "deploy_data_writes" {
  name          = "${var.service_name}-${var.service_role}-${var.env_name}-deploy-data-writes"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec_data_writes.rendered}"
  }
}