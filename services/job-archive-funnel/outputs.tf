# --------------------------------------------------------------------------------
# MODULE OUTPUTS
# --------------------------------------------------------------------------------
output "vpc_id" {
  value = "${data.terraform_remote_state.vpc.vpc_id}"
}

output "kms_master_key_alias" {
  value = "${module.kms_master_key.key_alias}"
}

output "kms_master_key_arn" {
  value = "${module.kms_master_key.key_arn}"
}

output "sqs_completed_tasks_name" {
  value = "${module.sqs_completed_tasks.queue_name}"
}

output "sqs_completed_tasks_url" {
  value = "${module.sqs_completed_tasks.queue_url}"
}

output "sqs_completed_tasks_url_ssm_path" {
  value = "${aws_ssm_parameter.ssm_sqs_completed_tasks_url.name}"
}

output "sqs_unprocessed_tests_name" {
  value = "${module.sqs_unprocessed_tests.queue_name}"
}

output "sqs_unprocessed_tests_name_ssm_path" {
  value = "${aws_ssm_parameter.ssm_sqs_unprocessed_tests_name.name}"
}

output "sqs_unprocessed_tests_url" {
  value = "${module.sqs_unprocessed_tests.queue_url}"
}

output "sqs_unprocessed_tests_url_ssm_path" {
  value = "${aws_ssm_parameter.ssm_sqs_unprocessed_tests_url.name}"
}

output "s3_raw_test_data_name" {
  value = "${module.s3_raw_test_data.bucket_id}"
}

output "s3_raw_test_data_arn" {
  value = "${module.s3_raw_test_data.bucket_arn}"
}

output "s3_raw_test_data_name_ssm_path" {
  value = "${aws_ssm_parameter.ssm_s3_raw_test_data_name.name}"
}

output "s3_task_artifacts_name_ssm_path" {
  value = "${aws_ssm_parameter.ssm_s3_task_artifacts_name.name}"
}

output "iam_role_funnel_lambda_name" {
  value = "${aws_iam_role.iam_role_funnel_lambda.name}"
}

output "iam_role_funnel_lambda_arn" {
  value = "${aws_iam_role.iam_role_funnel_lambda.arn}"
}

output "iam_role_funnel_lambda_name_ssm_path" {
  value = "${aws_ssm_parameter.ssm_iam_role_funnel_lambda_name.name}"
}

output "iam_role_funnel_lambda_arn_ssm_path" {
  value = "${aws_ssm_parameter.ssm_iam_role_funnel_lambda_arn.name}"
}

output "security_group_funnel_id" {
  value = "${aws_security_group.job_archive_funnel.id}"
}

output "security_group_funnel_name" {
  value = "${aws_security_group.job_archive_funnel.name}"
}
