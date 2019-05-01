##########################
# Codepipeline
##########################
resource "aws_codepipeline" "pipeline" {
  name     = "${var.service_name}-${var.service_role}-build-image"
  role_arn = "${aws_iam_role.codepipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.source.id}"
    type     = "S3"
  }

  stage {
    name = "source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["master-image"]

      configuration {
        Owner  = "${var.github_owner}"
        Repo   = "${var.github_repo}"
        Branch = "${var.github_branch}"
      }
    }
  }

  stage {
    name = "build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts = ["master-image"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        ProjectName = "${var.service_name}-${var.service_role}-build-image"
        PrimarySource = "Source"
      }
    }
  }
}
