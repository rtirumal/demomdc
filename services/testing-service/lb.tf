# ---------------------------------------------------------------------------------------------------------------------
# ALB
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_lb_target_group" "master" {
  name        = "${var.service_name}-${var.service_role}-${var.env_name}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/"
    interval            = 30
    matcher             = "200,403"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "master" {
  name            = "${var.service_name}-${var.service_role}-${var.env_name}"
  subnets         = ["${var.private_subnets}"]
  security_groups = ["${aws_security_group.master_lb_sg.id}","${data.terraform_remote_state.sg_office_access.office_access_sg_id}"]

  internal = true

  tags {
    Name             = "${var.service_name}-${var.service_role}-${var.env_name}"
    Environment = "${var.env_name}"
  }
}

resource "aws_lb_listener" "master" {
  load_balancer_arn = "${aws_lb.master.arn}"
  port              = "8080"
  protocol          = "HTTP"
  depends_on        = ["aws_lb_target_group.master"]

  default_action {
    target_group_arn = "${aws_lb_target_group.master.arn}"
    type             = "forward"
  }
}
