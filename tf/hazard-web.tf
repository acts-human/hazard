resource "aws_alb" "hazard_web" {
  name = "hazard-web-alb"
  internal = false

  security_groups = [
    "${aws_security_group.ecs.id}",
    "${aws_security_group.alb.id}",
  ]

  subnets = [
    "${module.base_vpc.public_subnets[0]}",
    "${module.base_vpc.public_subnets[1]}"
  ]
}

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
  load_balancer_arn = "${aws_alb.hazard_web.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.hazard_web.arn}"
    type = "forward"
  }

  depends_on = ["aws_alb_target_group.hazard_web"]
}

output "alb_dns_name" {
  value = "${aws_alb.hazard_web.dns_name}"
}

data "template_file" "hazard_web" {
  template = "${file("res/ecs-task-hazard-web.json.tpl")}"
  vars {
    IMAGE      = "medic30420/hazard-web:latest"
    AWS_REGION = "${var.AWS_REGION}"
  }
}

resource "aws_ecs_task_definition" "hazard_web" {
  family                   = "hazard-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" # TODO: duplicated in json task def
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
