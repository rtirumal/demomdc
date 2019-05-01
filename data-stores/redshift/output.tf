output "cluster_id" {
  description = "The Redshift cluster ID"
  value       = "${module.redshift.cluster_id}"
}

output "cluster_identifier" {
  description = "The Redshift cluster identifier"
  value       = "${module.redshift.cluster_identifier}"
}

output "cluster_type" {
  description = "The Redshift cluster type"
  value       = "${module.redshift.cluster_type}"
}

output "cluster_node_type" {
  description = "The type of nodes in the cluster"
  value       = "${module.redshift.cluster_node_type}"
}

output "cluster_database_name" {
  description = "The name of the default database in the Cluster"
  value       = "${module.redshift.cluster_database_name}"
}

output "cluster_availability_zone" {
  description = "The availability zone of the Cluster"
  value       = "${module.redshift.cluster_availability_zone}"
}

output "cluster_automated_snapshot_retention_period" {
  description = "The backup retention period"
  value       = "${module.redshift.cluster_automated_snapshot_retention_period}"
}

output "cluster_preferred_maintenance_window" {
  description = "The backup window"
  value       = "${module.redshift.cluster_preferred_maintenance_window}"
}

output "cluster_endpoint" {
  description = "The connection endpoint"
  value       = "${module.redshift.cluster_endpoint}"
}

output "cluster_hostname" {
  description = "The hostname of the Redshift cluster"
  value       = "${module.redshift.cluster_hostname}"
}

output "cluster_encrypted" {
  description = "Whether the data in the cluster is encrypted"
  value       = "${module.redshift.cluster_encrypted}"
}

output "cluster_security_groups" {
  description = "The security groups associated with the cluster"
  value       = "${module.redshift.cluster_security_groups}"
}

output "cluster_vpc_security_group_ids" {
  description = "The VPC security group ids associated with the cluster"
  value       = "${module.redshift.cluster_vpc_security_group_ids}"
}

output "cluster_port" {
  description = "The port the cluster responds on"
  value       = "${module.redshift.cluster_port}"
}

output "cluster_version" {
  description = "The version of Redshift engine software"
  value       = "${module.redshift.cluster_version}"
}

output "cluster_parameter_group_name" {
  description = "The name of the parameter group to be associated with this cluster"
  value       = "${module.redshift.cluster_parameter_group_name}"
}

output "cluster_subnet_group_name" {
  description = "The name of a cluster subnet group to be associated with this cluster"
  value       = "${module.redshift.cluster_subnet_group_name}"
}

output "cluster_public_key" {
  description = "The public key for the cluster"
  value       = "${module.redshift.cluster_public_key}"
}

output "cluster_revision_number" {
  description = "The specific revision number of the database in the cluster"
  value       = "${module.redshift.cluster_revision_number}"
}

output "subnet_group_id" {
  description = "The ID of Redshift subnet group created by this module"
  value       = "${module.redshift.subnet_group_id}"
}

output "parameter_group_id" {
  description = "The ID of Redshift parameter group created by this module"
  value       = "${module.redshift.parameter_group_id}"
}

output "log_bucket_id" {
  description = "Redshift s3 log bucket id"
  value       = "${aws_s3_bucket.logs.id}"
}

output "log_bucket_arn" {
  description = "Redshift s3 log bucket arn"
  value       = "${aws_s3_bucket.logs.arn}"
}

output "security_group_id" {
  description = "Redshift cluster vpc security group id"
  value       = "${aws_security_group.sg.id}"
}
