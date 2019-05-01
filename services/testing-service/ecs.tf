# ---------------------------------------------------------------------------------------------------------------------
# ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "cluster_master" {
  source           = "git@github.com:magento/tf-aws-ecs-cluster.git"
  aws_region       = "${var.aws_region}"
  ecs_cluster_name = "${var.service_name}-${var.service_role}-${var.env_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "task_master" {
  template = "${file("${path.module}/files/${var.service_name}-${var.service_role}_task_definition.json")}"

  vars {
    name            = "${var.service_name}-${var.service_role}-${var.env_name}"
    task_image      = "${var.master_ecr_repo}:latest"
    container_port  = "${var.container_port}"
    host_port       = "${var.host_port}"
    protocol        = "${var.protocol}"
    task_memory     = "${var.task_memory}"
    aws_region      = "${var.aws_region}"
    log_group       = "${aws_cloudwatch_log_group.log.name}"
    datadog_api_key = "${data.aws_ssm_parameter.datadog_api_key.value}"
    service_name    = "${var.service_name}"
    env_name        = "${var.env_name}"
    jenkins_aws_user_id    = "${var.jenkins_aws_user_id}"
    jenkins_aws_access_key = "${data.aws_ssm_parameter.jenkins_aws_access_key.value}"
    jenkins_aws_secret_key = "${data.aws_ssm_parameter.jenkins_aws_secret_key.value}"
    agent_cluster_security_groups = "${aws_security_group.agent_sg.id}"
    agent_cluster_subnets = "${var.private_subnets_string}"
    aws_account_id = "${var.aws_account_id}"
  }
}

resource "aws_ecs_task_definition" "task_master" {
  family                   = "${var.service_name}-${var.service_role}-${var.env_name}"
  container_definitions    = "${data.template_file.task_master.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.task_cpu}"
  memory                   = "${var.task_memory}"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
  depends_on               = ["data.template_file.task_master"]
}

data "aws_ecs_task_definition" "task_master" {
  task_definition = "${aws_ecs_task_definition.task_master.family}"
  depends_on      = ["aws_ecs_task_definition.task_master"]
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS CLUSTER
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_ecs_service" "master" {
  name            = "${var.service_name}-${var.service_role}-${var.env_name}"
  task_definition = "${aws_ecs_task_definition.task_master.family}:${max("${aws_ecs_task_definition.task_master.revision}", "${data.aws_ecs_task_definition.task_master.revision}")}"
  launch_type     = "FARGATE"
  cluster         = "${module.cluster_master.cluster_arn}"
  desired_count   = "${var.service_desired_count}"
  # lifecycle {
  #   ignore_changes = ["desired_count"]
  # }

  network_configuration {
    security_groups  = ["${aws_security_group.master_sg.id}"]
    subnets          = ["${var.private_subnets}"]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = "${aws_lb_target_group.master.arn}"
    container_name   = "${var.service_name}-${var.service_role}-${var.env_name}"
    container_port   = "8080"
  }
}
