# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE FARGATE CLUSTER INSTANCE SECURITY GROUP
# Limits which ports are allowed inbound and outbound. We export the security group id as an output so users of this
# module can add their own custom rules.
# ---------------------------------------------------------------------------------------------------------------------

# Note that we do not define ingress and egress rules inline. This is because users of this terraform module might
# want to add arbitrary rules to this security group. See:
# https://www.terraform.io/docs/providers/aws/r/security_group.html.
resource "aws_security_group" "fargate" {
  name        = "${var.service_name}-cluster"
  description = "For Fargate Network Interfaces in the ECS Cluster."
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
}

# Allow all outbound traffic from the ECS Cluster
resource "aws_security_group_rule" "allow_outbound_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.fargate.id}"
}

# Allow inbound traffic from CIDR blocks such as VPC subnets or Corporate Office Network
resource "aws_security_group_rule" "allow_inbound_from_cidr_blocks" {
  count = "${signum(length(var.allow_inbound_from_cidr_blocks))}"

  type      = "ingress"
  from_port = "${var.host_port}"
  to_port   = "${var.host_port}"
  protocol  = "${var.protocol}"

  cidr_blocks       = ["${var.allow_inbound_from_cidr_blocks}"]
  security_group_id = "${aws_security_group.fargate.id}"
}

# Allow inbound traffic from CIDR blocks such as VPC subnets or Corporate Office Network on port 443
resource "aws_security_group_rule" "allow_inbound_from_cidr_blocks_on_443" {
  count = "${signum(length(var.allow_inbound_from_cidr_blocks))}"

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "${var.protocol}"

  cidr_blocks       = ["${var.allow_inbound_from_cidr_blocks}"]
  security_group_id = "${aws_security_group.fargate.id}"
}

# Allow traffic in from the public internet on 443
resource "aws_security_group_rule" "ingress_443_from_internet" {
  count             = "${var.public_access_enabled ? 1 : 0}" #Optional public access.
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.fargate.id}"
  description       = "Port 443 ingress from Internet"
}

# Allow inbound traffic from a list of specific security groups for port of container
resource "aws_security_group_rule" "allow_inbound_from_security_groups" {
  count = "${length(var.allow_inbound_from_security_group_ids)}"

  type      = "ingress"
  from_port = "${var.host_port}"
  to_port   = "${var.host_port}"
  protocol  = "${var.protocol}"

  source_security_group_id = "${element(var.allow_inbound_from_security_group_ids, count.index)}"
  security_group_id        = "${aws_security_group.fargate.id}"
}

# Allow inbound traffic from a list of specific security groups for port 443
resource "aws_security_group_rule" "allow_inbound_from_security_groups_443" {
  count = "${length(var.allow_inbound_from_security_group_ids)}"

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "${var.protocol}"

  source_security_group_id = "${element(var.allow_inbound_from_security_group_ids, count.index)}"
  security_group_id        = "${aws_security_group.fargate.id}"
}

#The following rule is needed, it allows the Load Balencer to talk to the application on the container port.
resource "aws_security_group_rule" "container_port_ingress_from_fargateapp_lb_sg" {
  type                     = "ingress"
  from_port                = "${var.container_port}"
  to_port                  = "${var.container_port}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.fargate.id}"
  source_security_group_id = "${aws_security_group.fargate.id}"
  description              = "container_port ingress from fargateapp lb sg"
}
