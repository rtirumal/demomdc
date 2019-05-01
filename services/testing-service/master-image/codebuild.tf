#####################################
# Codebuild Build Master Container
#####################################\
data "template_file" "buildspec" {
  template = "${file("${path.module}/files/buildspec.yml")}"

  vars {
    aws_region          = "${var.aws_region}"
    jenkins_keys_bucket = "${var.jenkins_keys_bucket_id}"
    deploy_hash_dev     = "${aws_ssm_parameter.deploy_hash_dev.name}"
    deploy_hash_stage     = "${aws_ssm_parameter.deploy_hash_stage.name}"
    deploy_hash_prod     = "${aws_ssm_parameter.deploy_hash_prod.name}"
    master_ecr_repo     = "${var.master_ecr_repo}"
  }
}

resource "aws_codebuild_project" "master_build" {
  name          = "${var.service_name}-${var.service_role}-build-image"
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
