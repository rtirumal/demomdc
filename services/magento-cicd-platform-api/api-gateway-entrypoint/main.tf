provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.0"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${var.aws_account_id}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE REMOTE STATE STORAGE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # Only allow this Terraform version. Note that if you upgrade to a newer version, Terraform won't allow you to use an
  # older version, so when you upgrade, you should upgrade everyone on your team and your CI servers all at once.
  required_version = "~> 0.11.10"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    region = "${var.terraform_state_aws_region}"
    bucket = "${var.terraform_state_s3_bucket}"
    key    = "${var.aws_region}/${var.vpc_name}/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc_engcom" {
  backend = "s3"

  config {
    region = "${var.vpc_engcom_terraform_state_aws_region}"
    bucket = "${var.vpc_engcom_terraform_state_s3_bucket}"
    key    = "${var.vpc_engcom_terraform_state_s3_key}/terraform.tfstate"
  }
}

resource "aws_api_gateway_rest_api" "testing_service_api_entrypoint" {
  name        = "${var.api_gateway_name}-${var.environment}"
  description = "${var.api_gateway_description}"

  endpoint_configuration {
    types = ["PRIVATE"]
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:i3wo1f3ffk/*"
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:i3wo1f3ffk/*",
      "Condition": {
        "StringNotEquals": {
          "aws:SourceVpc": [
            "${data.terraform_remote_state.vpc_engcom.vpc_id}",
            "${data.terraform_remote_state.vpc.vpc_id}"
          ]
        }
      }
    }
  ]
}
  EOF
}

# ---------------------------------------------------------------------------------------------------------------------
# RESOURCE TREE DEFINITIONS
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# /job-archive resource 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "api_gateway_job_archive_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  parent_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.root_resource_id}"
  path_part   = "job-archive"
}

# ---------------------------------------------------------------------------------------------------------------------
# /job-archive/artifacts resource 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "api_gateway_job_archive_artifacts_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  parent_id   = "${aws_api_gateway_resource.api_gateway_job_archive_resource.id}"
  path_part   = "artifacts"
}

# ---------------------------------------------------------------------------------------------------------------------
# /job-archive/artifacts/{id} resource 
# Maps to job-archive-api-stage-artifacts Lambda Function
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "api_gateway_job_archive_artifacts_id_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  parent_id   = "${aws_api_gateway_resource.api_gateway_job_archive_artifacts_resource.id}"
  path_part   = "{id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# /job-archive/metadata resource 
# Maps to job-archive-api-stage-metadata Lambda Function
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "api_gateway_job_archive_metadata_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  parent_id   = "${aws_api_gateway_resource.api_gateway_job_archive_resource.id}"
  path_part   = "metadata"
}

# ---------------------------------------------------------------------------------------------------------------------
# /job-archive/task resource 
# Maps to job-archive-api-stage-task Lambda Function
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "api_gateway_job_archive_task_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  parent_id   = "${aws_api_gateway_resource.api_gateway_job_archive_resource.id}"
  path_part   = "task"
}

# ---------------------------------------------------------------------------------------------------------------------
# /testing-service resource 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "api_gateway_testing_service_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  parent_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.root_resource_id}"
  path_part   = "testing-service"
}

# ---------------------------------------------------------------------------------------------------------------------
# /job-archive/task resource 
# Maps to testing-service-api-stage-citest Lambda Function
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "api_gateway_testing_service_citest_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  parent_id   = "${aws_api_gateway_resource.api_gateway_testing_service_resource.id}"
  path_part   = "citest"
}

# ---------------------------------------------------------------------------------------------------------------------
# MOCK TYPE OPTIONS HTTP method under /job-archive/
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_job_archive_options_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_job_archive_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_job_archive_mock_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_options_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_job_archive_mock_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id          = "${aws_api_gateway_resource.api_gateway_job_archive_resource.id}"
  http_method          = "${aws_api_gateway_method.api_gateway_job_archive_options_method.http_method}"
  type                 = "MOCK"
  passthrough_behavior = "NEVER"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_job_archive_options_method"]
}

resource "aws_api_gateway_integration_response" "api_gateway_job_archive_mock_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_job_archive_mock_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_job_archive_mock_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# MOCK TYPE OPTIONS HTTP method under /job-archive/artifacts/{id}
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_job_archive_artifacts_id_options_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_job_archive_artifacts_id_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_job_archive_artifacts_id_mock_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_artifacts_id_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_artifacts_id_options_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_job_archive_artifacts_id_mock_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id          = "${aws_api_gateway_resource.api_gateway_job_archive_artifacts_id_resource.id}"
  http_method          = "${aws_api_gateway_method.api_gateway_job_archive_artifacts_id_options_method.http_method}"
  type                 = "MOCK"
  passthrough_behavior = "NEVER"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_job_archive_artifacts_id_options_method"]
}

resource "aws_api_gateway_integration_response" "api_gateway_job_archive_artifacts_id_mock_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_artifacts_id_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_artifacts_id_options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_job_archive_artifacts_id_mock_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_job_archive_artifacts_id_mock_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA_PROXY GET HTTP method under /job-archive/artifacts/{id}
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_job_archive_artifacts_id_get_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_job_archive_artifacts_id_resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_job_archive_artifacts_id_get_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_artifacts_id_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_artifacts_id_get_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "api_gateway_job_archive_artifacts_id_get_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id             = "${aws_api_gateway_resource.api_gateway_job_archive_artifacts_id_resource.id}"
  http_method             = "${aws_api_gateway_method.api_gateway_job_archive_artifacts_id_get_method.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.job_archive_artifacts_lambda_arn}:${var.job_archive_artifacts_lambda_alias_name}/invocations"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_job_archive_artifacts_id_get_method"]
}

resource "aws_lambda_permission" "apigw_artifacts_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.job_archive_artifacts_lambda_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.execution_arn}/*/*/*"
  qualifier     = "${var.job_archive_artifacts_lambda_alias_name}"
}

resource "aws_api_gateway_integration_response" "api_gateway_job_archive_artifacts_id_get_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_artifacts_id_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_artifacts_id_get_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_job_archive_artifacts_id_get_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_job_archive_artifacts_id_get_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# MOCK TYPE OPTIONS HTTP method under /job-archive/metadata
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_job_archive_metadata_options_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_job_archive_metadata_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_job_archive_metadata_mock_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_metadata_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_metadata_options_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_job_archive_metadata_mock_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id          = "${aws_api_gateway_resource.api_gateway_job_archive_metadata_resource.id}"
  http_method          = "${aws_api_gateway_method.api_gateway_job_archive_metadata_options_method.http_method}"
  type                 = "MOCK"
  passthrough_behavior = "NEVER"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_job_archive_metadata_options_method"]
}

resource "aws_api_gateway_integration_response" "api_gateway_job_archive_metadata_mock_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_metadata_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_metadata_options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_job_archive_metadata_mock_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_job_archive_metadata_mock_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA_PROXY TYPE POST HTTP method under /job-archive/metadata
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_job_archive_metadata_post_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_job_archive_metadata_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_job_archive_metadata_post_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_metadata_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_metadata_post_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "api_gateway_job_archive_metadata_post_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id             = "${aws_api_gateway_resource.api_gateway_job_archive_metadata_resource.id}"
  http_method             = "${aws_api_gateway_method.api_gateway_job_archive_metadata_post_method.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.job_archive_metadata_lambda_arn}:${var.job_archive_metadata_lambda_alias_name}/invocations"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_job_archive_metadata_post_method"]
}

resource "aws_lambda_permission" "apigw_metadata_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.job_archive_metadata_lambda_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.execution_arn}/*/*/*"
  qualifier     = "${var.job_archive_metadata_lambda_alias_name}"
}

resource "aws_api_gateway_integration_response" "api_gateway_job_archive_metadata_post_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_metadata_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_metadata_post_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_job_archive_metadata_post_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_job_archive_metadata_post_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# MOCK TYPE OPTIONS HTTP method under /job-archive/task
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_job_archive_task_options_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_job_archive_task_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_job_archive_task_mock_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_task_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_task_options_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_job_archive_task_mock_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id          = "${aws_api_gateway_resource.api_gateway_job_archive_task_resource.id}"
  http_method          = "${aws_api_gateway_method.api_gateway_job_archive_task_options_method.http_method}"
  type                 = "MOCK"
  passthrough_behavior = "NEVER"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_job_archive_task_options_method"]
}

resource "aws_api_gateway_integration_response" "api_gateway_job_archive_task_mock_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_task_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_task_options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_job_archive_task_mock_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_job_archive_task_mock_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA_PROXY TYPE POST HTTP method under /job-archive/task
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_job_archive_task_post_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_job_archive_task_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_job_archive_task_post_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_task_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_task_post_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "api_gateway_job_archive_task_post_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id             = "${aws_api_gateway_resource.api_gateway_job_archive_task_resource.id}"
  http_method             = "${aws_api_gateway_method.api_gateway_job_archive_task_post_method.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.job_archive_task_lambda_arn}:${var.job_archive_task_lambda_alias_name}/invocations"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_job_archive_task_post_method"]
}

resource "aws_lambda_permission" "apigw_task_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.job_archive_task_lambda_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.execution_arn}/*/*/*"
  qualifier     = "${var.job_archive_task_lambda_alias_name}"
}

resource "aws_api_gateway_integration_response" "api_gateway_job_archive_task_post_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_job_archive_task_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_job_archive_task_post_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_job_archive_task_post_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_job_archive_task_post_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# MOCK TYPE OPTIONS HTTP method under /testing-service/
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_testing_service_options_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_testing_service_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_testing_service_mock_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_testing_service_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_testing_service_options_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_testing_service_mock_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id          = "${aws_api_gateway_resource.api_gateway_testing_service_resource.id}"
  http_method          = "${aws_api_gateway_method.api_gateway_testing_service_options_method.http_method}"
  type                 = "MOCK"
  passthrough_behavior = "NEVER"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_testing_service_options_method"]
}

resource "aws_api_gateway_integration_response" "api_gateway_testing_service_mock_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_testing_service_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_testing_service_options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_testing_service_mock_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_testing_service_mock_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# MOCK TYPE OPTIONS HTTP method under /testing-service/citest
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_testing_service_citest_options_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_testing_service_citest_resource.id}"
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_testing_service_citest_mock_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_testing_service_citest_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_testing_service_citest_options_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "api_gateway_testing_service_citest_mock_integration" {
  rest_api_id          = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id          = "${aws_api_gateway_resource.api_gateway_testing_service_citest_resource.id}"
  http_method          = "${aws_api_gateway_method.api_gateway_testing_service_citest_options_method.http_method}"
  type                 = "MOCK"
  passthrough_behavior = "NEVER"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_testing_service_citest_options_method"]
}

resource "aws_api_gateway_integration_response" "api_gateway_testing_service_citest_mock_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_testing_service_citest_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_testing_service_citest_options_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_testing_service_citest_mock_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_testing_service_citest_mock_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA_PROXY TYPE POST HTTP method under /testing-service/citest
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_gateway_testing_service_citest_post_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id   = "${aws_api_gateway_resource.api_gateway_testing_service_citest_resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_testing_service_citest_post_method_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_testing_service_citest_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_testing_service_citest_post_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "api_gateway_testing_service_citest_post_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id             = "${aws_api_gateway_resource.api_gateway_testing_service_citest_resource.id}"
  http_method             = "${aws_api_gateway_method.api_gateway_testing_service_citest_post_method.http_method}"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.testing_service_citest_lambda_arn}:${var.testing_service_citest_lambda_alias_name}/invocations"
  integration_http_method = "POST"

  request_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method.api_gateway_testing_service_citest_post_method"]
}

resource "aws_lambda_permission" "apigw_citest_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${var.testing_service_citest_lambda_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.execution_arn}/*/*/*"
  qualifier     = "${var.testing_service_citest_lambda_alias_name}"
}

resource "aws_api_gateway_integration_response" "api_gateway_testing_service_citest_post_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  resource_id = "${aws_api_gateway_resource.api_gateway_testing_service_citest_resource.id}"
  http_method = "${aws_api_gateway_method.api_gateway_testing_service_citest_post_method.http_method}"
  status_code = "${aws_api_gateway_method_response.api_gateway_testing_service_citest_post_method_response.status_code}"

  response_templates = {
    "application/json" = "Empty"
  }

  depends_on = ["aws_api_gateway_method_response.api_gateway_testing_service_citest_post_method_response"]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOYMENT RESOURCE FOR THIS REST API
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "testing_service_api_entrypoint_deployment" {
  depends_on = [
    "aws_api_gateway_integration.api_gateway_job_archive_mock_integration",
    "aws_api_gateway_integration.api_gateway_job_archive_artifacts_id_mock_integration",
    "aws_api_gateway_integration.api_gateway_job_archive_artifacts_id_get_integration",
    "aws_api_gateway_integration.api_gateway_job_archive_metadata_mock_integration",
    "aws_api_gateway_integration.api_gateway_job_archive_metadata_post_integration",
    "aws_api_gateway_integration.api_gateway_job_archive_task_mock_integration",
    "aws_api_gateway_integration.api_gateway_job_archive_task_post_integration",
    "aws_api_gateway_integration.api_gateway_testing_service_mock_integration",
    "aws_api_gateway_integration.api_gateway_testing_service_citest_mock_integration",
    "aws_api_gateway_integration.api_gateway_testing_service_citest_post_integration",
  ]

  rest_api_id       = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  stage_name        = "${var.environment}"
  stage_description = <<DESCRIPTION
${var.job_archive_artifacts_lambda_name} version: ${var.job_archive_artifacts_lambda_alias_name}
${var.job_archive_metadata_lambda_name} version: ${var.job_archive_metadata_lambda_alias_name}
${var.job_archive_task_lambda_name} version: ${var.job_archive_task_lambda_alias_name}
${var.testing_service_citest_lambda_name} version: ${var.testing_service_citest_lambda_alias_name}
DESCRIPTION

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_method_settings" "api_gateway_settings" {
  rest_api_id = "${aws_api_gateway_rest_api.testing_service_api_entrypoint.id}"
  stage_name  = "${aws_api_gateway_deployment.testing_service_api_entrypoint_deployment.stage_name}"
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}
