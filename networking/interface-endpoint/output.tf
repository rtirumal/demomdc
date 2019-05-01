# ---------------------------------------------------------------------------------------------------------------------
# ENDPOINT
# ---------------------------------------------------------------------------------------------------------------------

output "endpoint_id" {
  value = "${aws_vpc_endpoint.endpoint.id}"
}

output "endpoint_state" {
  value = "${aws_vpc_endpoint.endpoint.state}"
}

output "endpoint_network_interface_ids" {
  value = ["${aws_vpc_endpoint.endpoint.network_interface_ids}"]
}

output "endpoint_dns_entry" {
  value = "${aws_vpc_endpoint.endpoint.state}"
}

# ---------------------------------------------------------------------------------------------------------------------
# SG
# ---------------------------------------------------------------------------------------------------------------------

output "ep_sg_id" {
  value = "${aws_security_group.endpoint.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# PARAMETER STORE
# ---------------------------------------------------------------------------------------------------------------------

output "ep_dns_name" {
  value = "${aws_ssm_parameter.endpoint_dns_name.name}"
}
