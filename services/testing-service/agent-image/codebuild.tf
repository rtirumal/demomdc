#####################################
# Codebuild Build Agent Container
#####################################

data "template_file" "buildspec" {
  template = "${file("${path.module}/buildspec.yml")}"

  vars {
    aws_account_id    = "${var.aws_account_id}"
    aws_region        = "${var.aws_region}"
    env_name          = "${var.env_name}"
    service_name      = "${var.service_name}"
    github_branch     = "${var.github_branch}"
    github_org        = "${var.github_org}"
    github_repo       = "${var.github_repo}"
    php_version_full  = "${var.php_version_full}"
    ecr_repo_name     = "${aws_ecr_repository.ecr_agent_repo.name}"
  }
}

resource "aws_codebuild_project" "agent_build" {
  name          = "${var.service_name}-${var.service_role}-build-image-p${var.php_version_short}"
  build_timeout = "120"
  description = "Build Jenkins agent docker image for p${var.php_version_short}"
  service_role  = "${data.terraform_remote_state.acct_level_resources.codebuild_role_agent_build_arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/docker:18.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }
  
  source {
    type      = "S3"
    buildspec = "${data.template_file.buildspec.rendered}"
    location = "${data.terraform_remote_state.acct_level_resources.placeholder_bucket_id}/placeholder.zip"
  }
}
