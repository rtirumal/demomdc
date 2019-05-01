##########################
# Codepipeline
##########################
resource "aws_codepipeline" "pipeline" {
  name     = "${var.service_name}-${var.env_name}-deploy"
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
      output_artifacts = ["fargateapp-image"]

      configuration {
        PollForSourceChanges = false
        Owner                = "${var.github_owner}"
        Repo                 = "${var.github_repo}"
        Branch               = "${var.github_branch}"
        OAuthToken           = "${data.aws_ssm_parameter.github_oauth.value}" #This is used by AWS to access github.
      }
    }
  }

  stage {
    name = "build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["fargateapp-image"]

      #input_artifacts  = ["source-${var.service_name}-${var.env_name}-deploy"]
      output_artifacts = ["imagedefinitions"]

      configuration {
        #ProjectName = "${var.service_name}-${var.env_name}-build-image"
        ProjectName   = "${var.service_name}-${var.env_name}-deploy"
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
        ClusterName = "${module.cluster_fargateapp.cluster_arn}"
        ServiceName = "${aws_ecs_service.fargateapp.name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

# A shared secret between GitHub and AWS that allows AWS
# CodePipeline to authenticate the request came from GitHub.
# Would probably be better to pull this from the environment
# or something like SSM Parameter Store.
resource "random_string" "webhook_secret" {
  length = 32

  # Special characters are not allowed in webhook secret (AWS silently ignores webhook callbacks)
  special = false
}

resource "aws_codepipeline_webhook" "webhook" {
  name            = "${var.service_name}-${var.env_name}-codepipeline-webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = "${aws_codepipeline.pipeline.name}"

  authentication_configuration {
    secret_token = "${random_string.webhook_secret.result}"
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }

  lifecycle {
    # This is required for idempotency
    ignore_changes = ["authentication_configuration.secret_token"]
  }
}

##########################
# Github WebHook
##########################
# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "webhook" {
  repository = "${var.github_repo}" #${var.github_owner}/

  name = "web" # This is required to be "web"

  configuration {
    url          = "${aws_codepipeline_webhook.webhook.url}"
    content_type = "json"
    insecure_ssl = false                                     #Why would this be set to true? That was the default.
    secret       = "${random_string.webhook_secret.result}"
  }

  //events = ["push"]
  events = [
    "push",

    /*"issue_comment",*/
    "pull_request",

    "pull_request_review",
    "pull_request_review_comment",
  ]

  depends_on = ["aws_codepipeline_webhook.webhook"]

  lifecycle {
    # This is required for idempotency
    ignore_changes = ["configuration.secret"]
  }
}
