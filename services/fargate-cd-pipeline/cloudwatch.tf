#############################
# Cloudwatch Log Group
#############################
resource "aws_cloudwatch_log_group" "fargateapp" {
  name = "${var.service_name}-${var.env_name}"

  tags {
    Environment = "${var.env_name}"
    Application = "${var.service_name}"
    Role        = "${var.service_role}"
  }
}
