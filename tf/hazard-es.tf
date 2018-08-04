resource "aws_alb_target_group" "hazard_es" {
  name = "hazard-es-alb-tg"
  protocol = "HTTP"
  port = "9200"
  vpc_id = "${module.base_vpc.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_alb_listener" "hazard_es" {
  load_balancer_arn = "${aws_alb.hazard.arn}"
  port = "9200"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.hazard_es.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.hazard_es"]
}

data "template_file" "hazard_es" {
  template = "${file("res/ecs-task-hazard-es.json.tpl")}"
  vars {
    IMAGE          = "medic30420/hazard-es:latest"
    AWS_REGION     = "${var.AWS_REGION}"
    LOG_GROUP      = "${aws_cloudwatch_log_group.hazard.name}"
  }
}

resource "aws_ecs_task_definition" "hazard_es" {
  family                   = "hazard-es"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 1024
  container_definitions    = "${data.template_file.hazard_es.rendered}"
  execution_role_arn       = "${aws_iam_role.ecs_task_assume.arn}"
}

resource "aws_ecs_service" "hazard_es" {
  name            = "hazard-es"
  cluster         = "${aws_ecs_cluster.fargate.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.hazard_es.arn}"
  desired_count   = 1

  network_configuration = {
    subnets = ["${module.base_vpc.private_subnets[0]}"]
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  load_balancer {
   target_group_arn = "${aws_alb_target_group.hazard_es.arn}"
   container_name = "hazard-es"
   container_port = 9200
  }

  depends_on = [
    "aws_alb_listener.hazard_es"
  ]
}
