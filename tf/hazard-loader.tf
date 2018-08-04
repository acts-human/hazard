data "template_file" "hazard_loader" {
  template = "${file("res/ecs-task-hazard-loader.json.tpl")}"
  vars {
    IMAGE          = "medic30420/hazard-loader:latest"
    AWS_REGION     = "${var.AWS_REGION}"
    ES_HOST        = "https://${aws_elasticsearch_domain.hazard.endpoint}"
    LOG_GROUP      = "${aws_cloudwatch_log_group.hazard.name}"
  }
}

resource "aws_ecs_task_definition" "hazard_loader" {
  family                   = "hazard-loader"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = "${data.template_file.hazard_loader.rendered}"
  execution_role_arn       = "${aws_iam_role.ecs_task_assume.arn}"
}

resource "aws_ecs_service" "hazard_loader" {
  name            = "hazard-loader"
  cluster         = "${aws_ecs_cluster.fargate.id}"
  launch_type     = "FARGATE"
  task_definition = "${aws_ecs_task_definition.hazard_loader.arn}"
  desired_count   = 1

  network_configuration = {
    subnets = ["${module.base_vpc.private_subnets[0]}"]
    security_groups = ["${aws_security_group.ecs.id}"]
  }
}
