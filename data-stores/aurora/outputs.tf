output "cluster_endpoint" {
  value = "${module.aurora.cluster_endpoint}"
}

output "reader_endpoint" {
  value = "${module.aurora.reader_endpoint}"
}

output "instance_endpoints" {
  value = "${module.aurora.instance_endpoints}"
}

output "cluster_id" {
  value = "${module.aurora.cluster_id}"
}

# Terraform does not provide an output for the cluster ARN, so we have to build it ourselves
output "cluster_arn" {
  value = "${module.aurora.cluster_arn}"
}

output "instance_ids" {
  value = "${module.aurora.instance_ids}"
}

output "port" {
  value = "${module.aurora.port}"
}

output "security_group_id" {
  value = "${module.aurora.security_group_id}"
}

output "db_name" {
  value = "${module.aurora.db_name}"
}

output "aurora_postgres_cluster_endpoint_ssm_path" {
  value = "${aws_ssm_parameter.ssm_aurora_postgres_cluster_endpoint.name}"
}

output "aurora_postgres_reader_endpoint_ssm_path" {
  value = "${aws_ssm_parameter.ssm_aurora_postgres_reader_endpoint.name}"
}

output "aurora_postgres_cluster_port_ssm_path" {
  value = "${aws_ssm_parameter.ssm_aurora_postgres_cluster_port.name}"
}

output "aurora_postgres_master_password_ssm_path" {
  value = "${aws_ssm_parameter.ssm_aurora_postgres_master_password.name}"
}

output "aurora_postgres_master_username_ssm_path" {
  value = "${aws_ssm_parameter.ssm_aurora_postgres_master_username.name}"
}

output "aurora_postgres_database_name_ssm_path" {
  value = "${aws_ssm_parameter.ssm_aurora_postgres_database_name.name}"
}
