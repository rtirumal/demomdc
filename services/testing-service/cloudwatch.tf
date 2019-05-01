# ---------------------------------------------------------------------------------------------------------------------
# CLOUDWATCH LOG GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "log" {
  name = "${var.service_name}-${var.env_name}"

  tags {
    Environment = "${var.env_name}"
    Application = "${var.service_name}"
  }
}
