######################################
# Route53
######################################
resource "aws_ssm_parameter" "deploy_hash_dev" {
  name      = "/${var.service_name}/dev/deploy-hash"
  type      = "String"
  value     = "latest"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
}
}

resource "aws_ssm_parameter" "deploy_hash_stage" {
  name      = "/${var.service_name}/stage/deploy-hash"
  type      = "String"
  value     = "latest"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
}
}

resource "aws_ssm_parameter" "deploy_hash_prod" {
  name      = "/${var.service_name}/prod/deploy-hash"
  type      = "String"
  value     = "latest"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
}
}

resource "aws_ssm_parameter" "currently_deployed_dev" {
  name      = "/${var.service_name}/dev/currently-deployed"
  type      = "String"
  value     = "latest"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
}
}

resource "aws_ssm_parameter" "currently_deployed_stage" {
  name      = "/${var.service_name}/stage/currently-deployed"
  type      = "String"
  value     = "latest"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
}
}

resource "aws_ssm_parameter" "currently_deployed_prod" {
  name      = "/${var.service_name}/prod/currently-deployed"
  type      = "String"
  value     = "latest"
  overwrite = false
  lifecycle {
  ignore_changes  = ["overwrite","value"]
}
}