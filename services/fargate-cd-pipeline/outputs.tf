##################################
# ECS
##################################
output "ecr_repo_fargateapp_arn" {
  value = "${aws_ecr_repository.fargateapp.arn}"
}

output "ecr_repo_fargateapp_name" {
  value = "${aws_ecr_repository.fargateapp.name}"
}

output "ecr_repo_fargateapp_registry_id" {
  value = "${aws_ecr_repository.fargateapp.registry_id}"
}

output "ecr_repo_fargateapp_url" {
  value = "${aws_ecr_repository.fargateapp.repository_url}"
}

output "ecs_cluster_fargateapp_arn" {
  value = "${module.cluster_fargateapp.cluster_arn}"
}

output "ecs_task_definition_fargateapp_arn" {
  value = "${aws_ecs_task_definition.task_fargateapp.arn}"
}

output "ecs_task_definition_fargateapp_family" {
  value = "${aws_ecs_task_definition.task_fargateapp.family}"
}

output "ecs_task_definition_fargateapp_revision" {
  value = "${aws_ecs_task_definition.task_fargateapp.revision}"
}

output "ecs_service_fargateapp_id" {
  value = "${aws_ecs_service.fargateapp.id}"
}

output "ecs_service_fargateapp_name" {
  value = "${aws_ecs_service.fargateapp.name}"
}

output "ecs_service_fargateapp_cluster" {
  value = "${aws_ecs_service.fargateapp.cluster}"
}

output "ecs_service_fargateapp_iam_role" {
  value = "${aws_ecs_service.fargateapp.iam_role}"
}

# output "ecs_service_fargateapp_desired_count" {
#   value = "${aws_ecs_service.fargateapp.desired_count}"
# }

##################################
# IAM
##################################

output "ecs_execution_role_arn" {
  value = "${aws_iam_role.ecs_execution_role.arn}"
}

output "ecs_execution_role_id" {
  value = "${aws_iam_role.ecs_execution_role.unique_id}"
}

##################################
# LB
##################################
output "fargateapp_lb_id" {
  value = "${aws_lb.fargateapp.id}"
}

output "fargateapp_lb_arn" {
  value = "${aws_lb.fargateapp.arn}"
}

output "fargateapp_lb_arn_suffix" {
  value = "${aws_lb.fargateapp.arn_suffix}"
}

output "fargateapp_lb_dns_name" {
  value = "${aws_lb.fargateapp.dns_name}"
}

output "fargateapp_lb_zone_id" {
  value = "${aws_lb.fargateapp.zone_id}"
}

output "fargateapp_lb_listener_id" {
  value = "${aws_lb_listener.fargateapp.id}"
}

output "fargateapp_lb_listener_arn" {
  value = "${aws_lb_listener.fargateapp.arn}"
}

output "fargateapp_lb_tg_arn" {
  value = "${aws_lb_target_group.fargateapp.arn}"
}

output "fargateapp_lb_tg_arn_suffix" {
  value = "${aws_lb_target_group.fargateapp.arn_suffix}"
}

output "fargateapp_lb_tg_id" {
  value = "${aws_lb_target_group.fargateapp.id}"
}

output "fargateapp_lb_tg_name" {
  value = "${aws_lb_target_group.fargateapp.name}"
}

# ##################################
# # Route53
# ##################################
output "fargateapp_fqdn" {
  description = "The Service FQDN"
  value       = "https://${aws_route53_record.sub_solutionascode_com_zone_ns_record.fqdn}"
}

# ##################################
# # SGs
# ##################################
output "fargate_sg_id" {
  value = "${aws_security_group.fargate.id}"
}

output "fargate_sg_arn" {
  value = "${aws_security_group.fargate.arn}"
}

output "fargate_sg_name" {
  value = "${aws_security_group.fargate.name}"
}
