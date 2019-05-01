# --------------------------------------------------------------------------------
# Job Archive Control Service Package Outputs
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# KMS Key
# --------------------------------------------------------------------------------
output "kms_master_key_alias" {
  value = "${module.kms_master_key.key_alias}"
}

output "kms_master_key_arn" {
  value = "${module.kms_master_key.key_arn}"
}

# --------------------------------------------------------------------------------
# Completed Tasks SNS Topic
# --------------------------------------------------------------------------------
output "sns_completed_tasks_name" {
  value = "${module.sns_completed_tasks.topic_name}"
}

output "sns_completed_tasks_display_name" {
  value = "${module.sns_completed_tasks.topic_display_name}"
}

output "sns_completed_tasks_arn" {
  value = "${module.sns_completed_tasks.topic_arn}"
}

output "sns_completed_tasks_policy" {
  value = "${module.sns_completed_tasks.topic_policy}"
}
# --------------------------------------------------------------------------------
output "sns_completed_tasks_name_ssm_path" {
  value = "${aws_ssm_parameter.ssm_sns_completed_tasks_name.name}"
}

output "sns_completed_tasks_display_name_ssm_path" {
  value = "${aws_ssm_parameter.ssm_sns_completed_tasks_display_name.name}"
}

output "sns_completed_tasks_arn_ssm_path" {
  value = "${aws_ssm_parameter.ssm_sns_completed_tasks_arn.name}"
}
# --------------------------------------------------------------------------------
