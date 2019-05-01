##########################
# ECR Repos
##########################
resource "aws_ecr_repository" "fargateapp" {
  name = "${var.service_name}-${var.env_name}"
}

##########################
# ECS Cluster
##########################

module "cluster_fargateapp" {
  source           = "git@github.com:magento/tf-aws-ecs-cluster.git"
  aws_region       = "${var.aws_region}"
  ecs_cluster_name = "${var.service_name}-${var.env_name}"
}

##########################
# ECS Task
##########################

data "template_file" "task_fargateapp" {
  #template = "${file("${path.module}/${var.service_name}_task_definition.json")}"
  template = "${file("${path.module}/files/fargateapp_task_definition.json")}"

  vars {
    name           = "${var.service_name}-${var.env_name}"
    task_image     = "${aws_ecr_repository.fargateapp.repository_url}:latest"
    container_port = "${var.container_port}"
    host_port      = "${var.host_port}"
    protocol       = "${var.protocol}"
    task_memory    = "${var.task_memory}"
    aws_region     = "${var.aws_region}"
    log_group      = "${aws_cloudwatch_log_group.fargateapp.name}"

    service_name = "${var.service_name}-${var.env_name}"
  }
}

resource "aws_ecs_task_definition" "task_fargateapp" {
  family                   = "${var.service_name}-${var.env_name}"
  container_definitions    = "${data.template_file.task_fargateapp.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.task_cpu}"
  memory                   = "${var.task_memory}"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
  depends_on               = ["data.template_file.task_fargateapp"]
}

data "aws_ecs_task_definition" "task_fargateapp" {
  task_definition = "${aws_ecs_task_definition.task_fargateapp.family}"
  depends_on      = ["aws_ecs_task_definition.task_fargateapp"]
}

##########################
# ECS Service
##########################

resource "aws_ecs_service" "fargateapp" {
  name            = "${var.service_name}-${var.env_name}"
  task_definition = "${aws_ecs_task_definition.task_fargateapp.family}:${max("${aws_ecs_task_definition.task_fargateapp.revision}", "${data.aws_ecs_task_definition.task_fargateapp.revision}")}"
  launch_type     = "FARGATE"
  cluster         = "${module.cluster_fargateapp.cluster_arn}"
  desired_count   = "${var.service_desired_count}"

  lifecycle {
    ignore_changes = ["desired_count"]
  }

  network_configuration {
    security_groups  = ["${aws_security_group.fargate.id}"]
    subnets          = ["${data.terraform_remote_state.vpc.private_app_subnet_ids}"]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.fargateapp.arn}"
    container_name   = "${var.service_name}-${var.env_name}"
    container_port   = "${var.container_port}"
  }
}
