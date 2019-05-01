##########################
# Codebuild Deploy
##########################
data "template_file" "buildspec" {
  template = "${file("${path.module}/files/buildspec.yml")}"

  vars {
    aws_region   = "${var.aws_region}"
    name         = "${var.service_name}-${var.env_name}"
    repo_uri     = "${aws_ecr_repository.fargateapp.repository_url}"                          # 981263594894.dkr.ecr.us-east-1.amazonaws.com/gh-fat-ce-prod
    endpoint_url = "https://${aws_route53_record.sub_solutionascode_com_zone_ns_record.fqdn}"

    #deploy_hash_stage     = "${aws_ssm_parameter.deploy_hash_stage.name}"
    #deploy_hash_prod     = "${aws_ssm_parameter.deploy_hash_prod.name}"
  }
}

resource "aws_codebuild_project" "deploy" {
  name          = "${var.service_name}-${var.env_name}-deploy"
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

    environment_variable {
      "name"  = "vpc_name"
      "value" = "${var.vpc_name}"
    }

    environment_variable {
      "name"  = "service_name"
      "value" = "${var.service_name}"
    }

    environment_variable {
      "name"  = "service_role"
      "value" = "${var.service_role}"
    }

    environment_variable {
      "name"  = "repository_url"
      "value" = "${aws_ecr_repository.fargateapp.name}"
    }

    environment_variable {
      "name"  = "endpoint_url"
      "value" = "https://${aws_route53_record.sub_solutionascode_com_zone_ns_record.fqdn}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "${data.template_file.buildspec.rendered}"
  }
}
