# ---------------------------------------------------------------------------------------------------------------------
# ECR Repo 
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_ssm_parameter" "master_repo" {
  name      = "/${var.service_name}/master/ecr-repo-url"
  type      = "String"
  value     = "${aws_ecr_repository.master.repository_url}"
  overwrite = true
}

# ---------------------------------------------------------------------------------------------------------------------
# github.com Token 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ssm_parameter" "codebuild_github_read_token_prod" {
  name      = "/${var.service_name}/prod/codebuild/github/read_token"
  type      = "SecureString"
  value     = "placeholder"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
  }
}

resource "aws_ssm_parameter" "codebuild_github_read_token_stage" {
  name      = "/${var.service_name}/stage/codebuild/github/read_token"
  type      = "SecureString"
  value     = "placeholder"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
  }
}

resource "aws_ssm_parameter" "jenkins_github_read_token_prod" {
  name      = "/${var.service_name}/prod/jenkins/github/read_token"
  type      = "SecureString"
  value     = "placeholder"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
  } 
}

resource "aws_ssm_parameter" "jenkins_github_write_token_prod" {
  name      = "/${var.service_name}/prod/jenkins/github/write_token"
  type      = "SecureString"
  value     = "placeholder"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
  } 
}

resource "aws_ssm_parameter" "jenkins_github_read_token_stage" {
  name      = "/${var.service_name}/stage/jenkins/github/read_token"
  type      = "SecureString"
  value     = "placeholder"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
  } 
}

resource "aws_ssm_parameter" "jenkins_github_write_token_stage" {
  name      = "/${var.service_name}/stage/jenkins/github/write_token"
  type      = "SecureString"
  value     = "placeholder"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
  } 
}

resource "aws_ssm_parameter" "jenkins_github_read_token_dev" {
  name      = "/${var.service_name}/dev/jenkins/github/read_token"
  type      = "SecureString"
  value     = "placeholder"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
  } 
}

resource "aws_ssm_parameter" "jenkins_github_write_token_dev" {
  name      = "/${var.service_name}/dev/jenkins/github/write_token"
  type      = "SecureString"
  value     = "placeholder"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
  } 
}