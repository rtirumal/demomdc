#####################################
# Codebuild Build Agent Container
#####################################

data "template_file" "buildspec" {
  template = "${file("${path.module}/buildspec.yml")}"

  vars {
    aws_account_id    = "${var.aws_account_id}"
    aws_region        = "${var.aws_region}"
    service_name      = "${var.service_name}"
    github_branch     = "${var.github_branch}"
    github_org        = "${var.github_org}"
    github_repo       = "${var.github_repo}"
    php_version       = "${var.php_version}"
    ecr_repo_name     = "${aws_ecr_repository.ecr_agent_repo.name}"
  }
}

resource "aws_codebuild_project" "agent_build" {
  name          = "${var.service_name}-build-image-${var.ecr_repo}" 
  build_timeout = "120"
  description = "Build docker base image for ${var.ecr_repo}"
  service_role  = "${var.service_role}" 
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
    location = "${var.acct_level_resources_s3_bucket}/placeholder.zip"
  }
}
