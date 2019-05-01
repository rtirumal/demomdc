output "vpc_name" {
  value = "${module.vpc.vpc_name}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${module.vpc.vpc_cidr_block}"
}

output "public_subnet_cidr_blocks" {
  value = ["${module.vpc.public_subnet_cidr_blocks}"]
}

output "private_app_subnet_cidr_blocks" {
  value = ["${module.vpc.private_app_subnet_cidr_blocks}"]
}

output "private_persistence_subnet_cidr_blocks" {
  value = ["${module.vpc.private_persistence_subnet_cidr_blocks}"]
}

output "public_subnet_ids" {
  value = ["${module.vpc.public_subnet_ids}"]
}

output "private_app_subnet_ids" {
  value = ["${module.vpc.private_app_subnet_ids}"]
}

output "private_persistence_subnet_ids" {
  value = ["${module.vpc.private_persistence_subnet_ids}"]
}

output "public_subnet_route_table_id" {
  value = "${module.vpc.public_subnet_route_table_id}"
}

output "private_app_subnet_route_table_ids" {
  value = ["${module.vpc.private_app_subnet_route_table_ids}"]
}

output "private_persistence_route_table_ids" {
  value = ["${module.vpc.private_persistence_route_table_ids}"]
}

output "nat_gateway_public_ips" {
  value = ["${module.vpc.nat_gateway_public_ips}"]
}

output "nat_gateway_public_ip_count" {
  value = "${length(module.vpc.nat_gateway_public_ips)}"
}

output "num_availability_zones" {
  value = "${module.vpc.num_availability_zones}"
}

output "availability_zones" {
  value = ["${module.vpc.availability_zones}"]
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

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------

 output "execute_api_sg_id" {
  value = "${aws_security_group.execute_api_sg.id}"
}
