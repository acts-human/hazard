resource "aws_alb_target_group" "hazard_api" {
  name = "hazard-api-alb-tg"
  protocol = "HTTP"
  port = "10010"
  vpc_id = "${module.base_vpc.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/api/v1/search?q=hawaii"
  }
}

resource "aws_alb_listener" "hazard_api" {
  load_balancer_arn = "${aws_alb.hazard.arn}"
  port = "10010"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.hazard_api.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.hazard_api"]
}

data "template_file" "hazard_api" {
  template = "${file("res/ecs-task-hazard-api.json.tpl")}"
  vars {
    IMAGE          = "medic30420/hazard-api:latest"
    AWS_REGION     = "${var.AWS_REGION}"
    ES_HOST        = "http://${aws_elasticsearch_domain.hazard.endpoint}"
    LOG_GROUP      = "${aws_cloudwatch_log_group.hazard.name}"
  }
}

resource "aws_ecs_task_definition" "hazard_api" {
  family                   = "hazard-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = "${data.template_file.hazard_api.rendered}"
  execution_role_arn       = "${aws_iam_role.ecs_task_assume.arn}"
}

resource "aws_ecs_service" "hazard_api" {
  name            = "hazard-api"
  cluster         = "${aws_ecs_cluster.fargate.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.hazard_api.arn}"
  desired_count   = 1

  network_configuration = {
    subnets = ["${module.base_vpc.private_subnets[0]}"]
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  load_balancer {
   target_group_arn = "${aws_alb_target_group.hazard_api.arn}"
   container_name = "hazard-api"
   container_port = 10010
  }

  depends_on = [
    "aws_alb_listener.hazard_api"
  ]
}
