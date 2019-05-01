# ---------------------------------------------------------------------------------------------------------------------
# DEADLETTER QUEUE
# ---------------------------------------------------------------------------------------------------------------------

module "sqs_deadletter" {
  source                     = "git@github.com:magento/tf-aws-sqs.git?ref=v1.1"
  name                       = "${var.service_name}-${var.env_name}-deadletter"
  delay_seconds              = "${var.deadletter_delay_seconds}"
  max_message_size           = "${var.deadletter_max_message_size}"
  message_retention_seconds  = "${var.deadletter_message_retention_seconds}"
  receive_wait_time_seconds  = "${var.deadletter_receive_wait_time_seconds}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${var.service_name}-${var.env_name}-deadletter-policy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": {"AWS": "${var.aws_account_id}"},
      "Action": "sqs:*",
      "Resource": "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:${var.service_name}-${var.env_name}-deadletter"
    }
  ]
}
POLICY

  tags = {
    Name        = "${var.service_name}-${var.env_name}-deadletter"
    Terraform   = "true"
    Environment = "${var.env_name}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# REQUEST QUEUE
# ---------------------------------------------------------------------------------------------------------------------

module "sqs_testreq" {
  source                     = "git@github.com:magento/tf-aws-sqs.git?ref=v1.1"
  name                       = "${var.service_name}-${var.env_name}-testreq"
  delay_seconds              = "${var.testreq_delay_seconds}"
  max_message_size           = "${var.testreq_max_message_size}"
  visibility_timeout_seconds = "${var.testreq_visibility_timeout_seconds}"
  message_retention_seconds  = "${var.testreq_message_retention_seconds}"
  receive_wait_time_seconds  = "${var.testreq_receive_wait_time_seconds}"
  redrive_policy             = "{\"deadLetterTargetArn\":\"${module.sqs_deadletter.arn}\",\"maxReceiveCount\":3}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${var.service_name}-${var.env_name}-testreq-policy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": {"AWS": "${var.aws_account_id}"},
      "Action": "sqs:*",
      "Resource": "arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:${var.service_name}-${var.env_name}-testreq"
    }
  ]
}
POLICY

  tags = {
    Name        = "${var.service_name}-${var.env_name}-testreq"
    Terraform   = "true"
    Environment = "${var.env_name}"
  }
}