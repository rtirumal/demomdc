# ---------------------------------------------------------------------------------------------------------------------
# CODEPIPELINE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_codepipeline" "pipeline" {
  name     = "${var.service_name}-${var.service_role}-${var.env_name}-deploy"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.source.id}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "S3"
      version  = "1"

      output_artifacts = ["source-${var.service_name}-${var.env_name}-deploy"]

      configuration {
        S3Bucket    = "${data.terraform_remote_state.acct_level_resources.placeholder_bucket_id}"
        S3ObjectKey = "placeholder.zip"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source-${var.service_name}-${var.env_name}-deploy"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${var.service_name}-${var.service_role}-${var.env_name}-deploy"
        PrimarySource = "Source"
      }
    }
  }

  stage {
    name = "deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration {
        ClusterName = "${module.cluster_master.cluster_arn}"
        ServiceName = "${aws_ecs_service.master.name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }

  stage {
    name = "data-writes"

    action {
      name             = "data-writes"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["imagedefinitions"]
      output_artifacts = ["uri"]

      configuration {
        ProjectName = "${var.service_name}-${var.service_role}-${var.env_name}-deploy-data-writes"
      }
    }
  }
}
