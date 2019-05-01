#################################################
# Route53 Hosted Zone Entries
#################################################

resource "aws_route53_record" "sub_solutionascode_com_zone_ns_record" {
  zone_id = "${var.zone_id}"
  name    = "${var.service_name}-${var.env_name}"
  type    = "CNAME"
  records = ["${aws_lb.fargateapp.dns_name}"]
  ttl     = "300"
}
