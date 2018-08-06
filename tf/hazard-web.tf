resource "aws_alb_target_group" "hazard_web" {
  name = "hazard-web-alb-tg"
  protocol = "HTTP"
  port = "3000"
  vpc_id = "${module.base_vpc.vpc_id}"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_alb_listener" "hazard_web" {
  load_balancer_arn = "${aws_alb.hazard.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.hazard_web.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.hazard_web"]
}

data "template_file" "hazard_web" {
  template = "${file("res/ecs-task-hazard-web.json.tpl")}"
  vars {
    IMAGE                  = "medic30420/hazard-web:latest"
    REACT_APP_API_BASE_URL = "http://${aws_alb.hazard.dns_name}:${aws_alb_listener.hazard_api.port}"
    AWS_REGION             = "${var.AWS_REGION}"
    LOG_GROUP              = "${aws_cloudwatch_log_group.hazard.name}"
  }
}

resource "aws_ecs_task_definition" "hazard_web" {
  family                   = "hazard-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = "${data.template_file.hazard_web.rendered}"
  execution_role_arn       = "${aws_iam_role.ecs_task_assume.arn}"
}

resource "aws_ecs_service" "hazard_web" {
  name            = "hazard-web"
  cluster         = "${aws_ecs_cluster.fargate.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.hazard_web.arn}"
  desired_count   = 1

  network_configuration = {
    subnets = ["${module.base_vpc.private_subnets[0]}"]
    security_groups = ["${aws_security_group.ecs.id}"]
  }

  load_balancer {
   target_group_arn = "${aws_alb_target_group.hazard_web.arn}"
   container_name = "hazard-web"
   container_port = 3000
  }

  depends_on = [
    "aws_alb_listener.hazard_web"
  ]
}
