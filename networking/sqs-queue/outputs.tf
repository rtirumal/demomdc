output "queue_arn" {
  value = "${module.sqs.queue_arn}"
}

output "queue_url" {
  value = "${module.sqs.queue_url}"
}

output "queue_arn_ssm" {
  value = "${aws_ssm_parameter.sqs_queue_endpoint.*.name}"
}
output "queue_url_ssm" {
  value = "${aws_ssm_parameter.sqs_queue_arn.*.name}"
}
