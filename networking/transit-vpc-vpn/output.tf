
# ---------------------------------------------------------------------------------------------------------------------
# VPN
# ---------------------------------------------------------------------------------------------------------------------

output "vgw_id" {
  description = "The ID of the VPN Gateway"
  value       = "${aws_vpn_gateway.this.id}"
}

output "virginia_vpn_connection_id" {
  description = "virginia_vpn_connection_id"
  value       = "${aws_vpn_connection.virginia.id}"
}

output "virginia_vpn_connection_cgw_id" {
  description = "virginia_vpn_connection_id"
  value       = "${aws_vpn_connection.virginia.customer_gateway_id}"
}

output "dublin_vpn_connection_id" {
  description = "dublin_vpn_connection_id"
  value       = "${aws_vpn_connection.dublin.id}"
}

output "dublin_vpn_connection_cgw_id" {
  description = "dublin_vpn_connection_id"
  value       = "${aws_vpn_connection.dublin.customer_gateway_id}"
}
