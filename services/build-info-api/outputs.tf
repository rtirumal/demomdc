# ---------------------------------------------------------------------------------------------------------------------
# MODULE OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------

output "security_group_name" {
  value = "${aws_security_group.build_info_api.name}"
}

output "security_group_id" {
  value = "${aws_security_group.build_info_api.id}"
}
