###########################
# LB
###########################

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LOAD BALANCER TARGET GROUP
# - An LB sends requests to one or more Targets (containers) contained in a Target Group. Typically, a Target Group is
#   scoped to the level of an Fargate Service, so we create one here.
# - The port number listed below in the aws_lb_target_group refers to the default port to which the LB will route traffic,
#   but because this value will be overridden by each container instance that boots up, the actual value doesn't matter.
# ---------------------------------------------------------------------------------------------------------------------

# - Note that the port 80 specified below is simply the default port for the Target Group. When a Docker container
#   actually launches, the actual port will be chosen dynamically, so the value specified below is arbitrary.
resource "aws_lb_target_group" "fargateapp" {
  name        = "${var.service_name}-${var.env_name}"
  port        = 80
  protocol    = "${var.alb_target_group_protocol}"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/health"
    interval            = 30
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "fargateapp" {
  name            = "${var.service_name}-${var.env_name}"
  subnets         = ["${data.terraform_remote_state.vpc.public_subnet_ids}"]
  security_groups = ["${aws_security_group.fargate.id}"]

  internal = false

  tags {
    Name        = "${var.service_name}-${var.env_name}-lb"
    Environment = "${var.env_name}"
  }
}

resource "aws_lb_listener" "fargateapp" {
  load_balancer_arn = "${aws_lb.fargateapp.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:us-east-1:981263594894:certificate/1f3e7e7a-3137-4587-bf3c-a5c3d6ce87aa"
  depends_on        = ["aws_lb_target_group.fargateapp"]

  default_action {
    target_group_arn = "${aws_lb_target_group.fargateapp.arn}"
    type             = "forward"
  }
}
