#################################################
# AWS Systems Manager Parameter store
#################################################

resource "aws_ssm_parameter" "ssm_fargate_endpoint" {
  count = "${var.register_service_enabled ? 1 : 0}"                          #Optional Register endpoint.
  name  = "/service-discovery/${var.service_name}/${var.env_name}"
  type  = "String"
  value = "${aws_route53_record.sub_solutionascode_com_zone_ns_record.fqdn}" # https:// has been removed from the beginning. 
}
