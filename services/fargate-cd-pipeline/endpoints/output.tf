# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------

output "execute_api_sg_id" {
  value = "${aws_security_group.execute_api_sg.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ENDPOINTS
# ---------------------------------------------------------------------------------------------------------------------

output "execute_api_ep_id" {
  value = "${aws_vpc_endpoint.execute_api_ep.id}"
}

output "execute_api_ep_state" {
  value = "${aws_vpc_endpoint.execute_api_ep.state}"
}

output "execute_api_ep_dns_entry" {
  value = "${aws_vpc_endpoint.execute_api_ep.dns_entry}"
}

output "execute_api_ep_global_dns_name" {
  value = "${aws_vpc_endpoint.execute_api_ep.dns_entry.0.dns_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# PARAMETER STORE
# ---------------------------------------------------------------------------------------------------------------------

output "execute_api_ep_global_dns_name_parameter_store_path" {
  value = "${aws_ssm_parameter.execute_api_ep_dns_name.name}"
}
