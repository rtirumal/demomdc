# --------------------------------------------------------------------------------
# PACKAGE OUTPUTS
# --------------------------------------------------------------------------------
output "security_group_name" {
  value = "${aws_security_group.job_archive_api.name}"
}

output "security_group_id" {
  value = "${aws_security_group.job_archive_api.id}"
}
