# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH 
# ---------------------------------------------------------------------------------------------------------------------

output "cloudwatch_log_group_master_arn" {
  value = "${aws_cloudwatch_log_group.log.arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS
# ---------------------------------------------------------------------------------------------------------------------


output "ecr_repo_master_url" {
  value = "${var.master_ecr_repo}"
}

output "ecs_cluster_master_arn" {
  value = "${module.cluster_master.cluster_arn}"
}

output "ecs_task_definition_master_arn" {
  value = "${aws_ecs_task_definition.task_master.arn}"
}

output "ecs_task_definition_master_family" {
  value = "${aws_ecs_task_definition.task_master.family}"
}

output "ecs_task_definition_master_revision" {
  value = "${aws_ecs_task_definition.task_master.revision}"
}

output "ecs_service_master_id" {
  value = "${aws_ecs_service.master.id}"
}

output "ecs_service_master_name" {
  value = "${aws_ecs_service.master.name}"
}

output "ecs_service_master_cluster" {
  value = "${aws_ecs_service.master.cluster}"
}

output "ecs_service_master_iam_role" {
  value = "${aws_ecs_service.master.iam_role}"
}

# output "ecs_service_master_desired_count" {
#   value = "${aws_ecs_service.master.desired_count}"
# }

# ---------------------------------------------------------------------------------------------------------------------
# IAM 
# ---------------------------------------------------------------------------------------------------------------------


output "ecs_execution_role_arn" {
  value = "${aws_iam_role.ecs_execution_role.arn}"
}

output "ecs_execution_role_id" {
  value = "${aws_iam_role.ecs_execution_role.unique_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# LB
# ---------------------------------------------------------------------------------------------------------------------

output "master_lb_id" {
  value = "${aws_lb.master.id}"
}

output "master_lb_arn" {
  value = "${aws_lb.master.arn}"
}

output "master_lb_arn_suffix" {
  value = "${aws_lb.master.arn_suffix}"
}

output "master_lb_dns_name" {
  value = "${aws_lb.master.dns_name}"
}

output "master_lb_zone_id" {
  value = "${aws_lb.master.zone_id}"
}

output "master_lb_listener_id" {
  value = "${aws_lb_listener.master.id}"
}

output "master_lb_listener_arn" {
  value = "${aws_lb_listener.master.arn}"
}

output "master_lb_tg_arn" {
  value = "${aws_lb_target_group.master.arn}"
}

output "master_lb_tg_arn_suffix" {
  value = "${aws_lb_target_group.master.arn_suffix}"
}

output "master_lb_tg_id" {
  value = "${aws_lb_target_group.master.id}"
}

output "master_lb_tg_name" {
  value = "${aws_lb_target_group.master.name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# PARAMETER STORE
# ---------------------------------------------------------------------------------------------------------------------

output "pstore_jenkins_artifacts_s3_name" {
  value = "${aws_ssm_parameter.jenkins_artifacts.name}"
}

output "pstore_jenkins_build_packages_s3_name" {
  value = "${aws_ssm_parameter.jenkins_build_packages.name}"
}


# ---------------------------------------------------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------------------------------------------------

output "s3_bucket_source_id" {
  value = "${aws_s3_bucket.source.id}"
}

output "s3_bucket_source_arn" {
  value = "${aws_s3_bucket.source.arn}"
}

output "s3_bucket_deploy_id" {
  value = "${aws_s3_bucket.deploy.id}"
}

output "s3_bucket_deploy_arn" {
  value = "${aws_s3_bucket.deploy.arn}"
}

output "s3_bucket_=jenkins_artifacta_id" {
  value = "${aws_s3_bucket.jenkins_artifacts.id}"
}

output "s3_bucket_jenkins_artifacts_arn" {
  value = "${aws_s3_bucket.jenkins_artifacts.arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# SGs
# ---------------------------------------------------------------------------------------------------------------------
output "master_lb_sg_id" {
  value = "${aws_security_group.master_lb_sg.id}"
}

output "master_lb_sg_arn" {
  value = "${aws_security_group.master_lb_sg.arn}"
}

output "master_lb_sg_name" {
  value = "${aws_security_group.master_lb_sg.name}"
}

output "master_sg_id" {
  value = "${aws_security_group.master_sg.id}"
}

output "master_sg_arn" {
  value = "${aws_security_group.master_sg.arn}"
}

output "master_sg_name" {
  value = "${aws_security_group.master_sg.name}"
}

output "agent_sg_id" {
  value = "${aws_security_group.agent_sg.id}"
}

output "agent_sg_arn" {
  value = "${aws_security_group.agent_sg.arn}"
}

output "agent_sg_name" {
  value = "${aws_security_group.agent_sg.name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# SQS
# ---------------------------------------------------------------------------------------------------------------------
output "deadletter_url" {
  value = "${module.sqs_deadletter.url}"
}

output "deadletter_arn" {
  value = "${module.sqs_deadletter.arn}"
}

output "testreq_url" {
  value = "${module.sqs_testreq.url}"
}

output "testreq_arn" {
  value = "${module.sqs_testreq.arn}"
}