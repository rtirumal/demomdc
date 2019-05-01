# ---------------------------------------------------------------------------------------------------------------------
# PACKAGE OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "queue_arn" {
  value = "${module.sqs.queue_arn}"
}

output "queue_url" {
  value = "${module.sqs.queue_url}"
}

output "job_archive_webhooks_sg_id" {
  value = "${aws_security_group.job_archive_webhooks.id}"
}
