# ---------------------------------------------------------------------------------------------------------------------
# MASTER LB SG
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_security_group" "master_lb_sg" {
  name        = "${var.service_name}-${var.env_name}-${var.service_role}-lb-sg"
  description = "master lb SG for ${var.env_name} VPC"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.service_name}-${var.env_name}-${var.service_role}-lb-sg"
  }
}

resource "aws_security_group_rule" "ingress_8080_from_austin_public_1" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["12.229.222.152/29"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Austin Office Public IP 1"
}

resource "aws_security_group_rule" "ingress_8080_from_austin_public_2" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["12.94.164.160/30"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Austin Office Public IP 2"
}

resource "aws_security_group_rule" "ingress_8080_from_austin_public_3" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["64.157.241.244/30"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Austin Office Public IP 3"
}

resource "aws_security_group_rule" "ingress_8080_from_austin_public_4" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["12.219.109.176/29"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Austin Office Public IP 3"
}

resource "aws_security_group_rule" "ingress_8080_from_austin_public_5" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["12.249.97.180/30"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Austin Office Public IP 3"
}

resource "aws_security_group_rule" "ingress_8080_from_campbell_public_1" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["50.205.135.72/29"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Campbell Office Public IP"
}

resource "aws_security_group_rule" "ingress_8080_from_campbell_public_2" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["12.124.76.224/30"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Campbell Office Public IP"
}

resource "aws_security_group_rule" "ingress_8080_from_campbell_public_3" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["12.51.199.128/29"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Campbell Office Public IP"
}

resource "aws_security_group_rule" "ingress_8080_from_barcelona_public_1" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["80.169.76.248/30"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Barcelona Office Public IP 1"
}

resource "aws_security_group_rule" "ingress_8080_from_barcelona_public_2" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["212.0.126.0/28"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Barcelona Office Public IP 2"
}

resource "aws_security_group_rule" "ingress_8080_from_barcelona_public_3" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["149.6.130.48/29"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Barcelona Office Public IP 2"
}

resource "aws_security_group_rule" "ingress_8080_from_kiev_public" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["195.14.124.0/23"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Kiev Office Public IP"
}

resource "aws_security_group_rule" "ingress_8080_from_la_public_1" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["68.170.69.176/29"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from LA Office Public IP 1"
}

resource "aws_security_group_rule" "ingress_8080_from_la_public_2" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["12.29.13.200/29"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from LA Office Public IP 2"
}

resource "aws_security_group_rule" "ingress_8080_from_la_public_3" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["12.245.131.196/30"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from LA Office Public IP 3"
}

resource "aws_security_group_rule" "ingress_8080_from_philly_public" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["38.140.197.64/29"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Philly Office Public IP"
}

resource "aws_security_group_rule" "ingress_8080_from_dubln_public_1" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["80.169.142.40/29"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Dublin Office Public IP"
}

resource "aws_security_group_rule" "ingress_8080_from_dublin_public_2" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["217.173.97.16/30"]
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from Dublin Office Public IP"
}

resource "aws_security_group_rule" "ingress_8080_from_agent_sg" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = "${aws_security_group.agent_sg.id}"
  security_group_id = "${aws_security_group.master_lb_sg.id}"
  description       = "Port 8080 ingress from agent sg"
}

resource "aws_security_group_rule" "8080_egress_to_master_sg" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.master_sg.id}"
  security_group_id        = "${aws_security_group.master_lb_sg.id}"
  description              = "8080 egress to master sg"
}

# ---------------------------------------------------------------------------------------------------------------------
# MASTER SG
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_security_group" "master_sg" {
  name        = "${var.service_name}-${var.env_name}-${var.service_role}-sg"
  description = "master SG for ${var.env_name} VPC"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.service_name}-${var.env_name}-${var.service_role}-sg"
  }
}

resource "aws_security_group_rule" "8080_ingress_from_master_lb_sg" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.master_sg.id}"
  source_security_group_id = "${aws_security_group.master_lb_sg.id}"
  description              = "8080 ingress from master lb sg"
}

resource "aws_security_group_rule" "8080_ingress_from_agent_sg" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.master_sg.id}"
  source_security_group_id = "${aws_security_group.agent_sg.id}"
  description              = "8080 ingress from agent sg"
}

resource "aws_security_group_rule" "50000_ingress_from_agent_sg" {
  type                     = "ingress"
  from_port                = 50000
  to_port                  = 50000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.master_sg.id}"
  source_security_group_id = "${aws_security_group.agent_sg.id}"
  description              = "50000 ingress from agent sg"
}

resource "aws_security_group_rule" "80_egress_to_all" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.master_sg.id}"
  description       = "80 egress to all"
}

resource "aws_security_group_rule" "443_egress_to_all" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.master_sg.id}"
  description       = "443 egress to all"
}

resource "aws_security_group_rule" "50000_egress_to_agent_from_master" {
  type                     = "egress"
  from_port                = 50000
  to_port                  = 50000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.master_sg.id}"
  source_security_group_id = "${aws_security_group.agent_sg.id}"
  description              = "8080 egress to agent sg"
}

# ---------------------------------------------------------------------------------------------------------------------
# AGENT SG
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_security_group" "agent_sg" {
  name        = "${var.service_name}-${var.env_name}-${var.service_role}-agent-sg"
  description = "master SG for ${var.env_name} VPC"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.service_name}-${var.env_name}-${var.service_role}-agent-sg"
  }
}

resource "aws_security_group_rule" "50000_ingress_from_master_sg_for_agent" {
  type                     = "ingress"
  from_port                = 50000
  to_port                  = 50000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.agent_sg.id}"
  source_security_group_id = "${aws_security_group.master_sg.id}"
  description              = "50000 ingress from master sg"
}

resource "aws_security_group_rule" "8080_egress_to_master_sg_for_agent" {
  type              = "egress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id        = "${aws_security_group.agent_sg.id}"
  source_security_group_id = "${aws_security_group.master_sg.id}"
  description       = "8080 egress to master sg"
}

resource "aws_security_group_rule" "50000_egress_to_master_sg_for_agent" {
  type              = "egress"
  from_port         = 50000
  to_port           = 50000
  protocol          = "tcp"
  security_group_id        = "${aws_security_group.agent_sg.id}"
  source_security_group_id = "${aws_security_group.master_sg.id}"
  description       = "50000 egress to master sg"
}

resource "aws_security_group_rule" "443_egress_to_all_agent" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.agent_sg.id}"
  description       = "443 egress to all"
}

resource "aws_security_group_rule" "80_egress_to_all_agent" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.agent_sg.id}"
  description       = "80 egress to all"
}