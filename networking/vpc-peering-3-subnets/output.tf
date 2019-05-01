output "aws_vpc_peering_connection_id" {
  value = "${aws_vpc_peering_connection.vpc_peering_connection.id}"
}

output "aws_vpc_peering_connection_accept_status" {
  value = "${aws_vpc_peering_connection.vpc_peering_connection.accept_status}"
}