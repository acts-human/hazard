provider "aws" {
  region = "${var.region}"
}

# resource "aws_instance" "example" {
#   ami           = "ami-bdc49dc5" // Ubuntu 18.04 server us-west-2
#   instance_type = "t2.micro"
# }

resource "aws_key_pair" "acts-human" {
  key_name = "acts-human-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_vpc" "hazard" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_ecs_cluster" "hazard" {
  name = "hazard"
}

resource "aws_internet_gateway" "hazard" {
  vpc_id = "${aws_vpc.hazard.id}"
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.hazard.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.hazard.id}"
  }
}

resource "aws_subnet" "hazard" {
  vpc_id = "${aws_vpc.hazard.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.availability_zone}"
}

resource "aws_route_table_association" "external-hazard" {
  subnet_id = "${aws_subnet.hazard.id}"
  route_table_id = "${aws_route_table.external.id}"
}

resource "aws_security_group" "load_balancers" {
  name = "load_balancers"
  description = "Allows all traffic"
  vpc_id = "${aws_vpc.hazard.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name = "ecs"
  description = "Allows all traffic"
  vpc_id = "${aws_vpc.hazard.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.load_balancers.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name = "ecs_service_role"
  assume_role_policy = "${file("res/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name = "ecs_service_role_policy"
  policy = "${file("res/ecs-service-role-policy.json")}"
  role = "${aws_iam_role.ecs_service_role.id}"
}

resource "aws_iam_role" "ecs_host_role" {
  name = "ecs_host_role"
  assume_role_policy = "${file("res/ecs-role.json")}"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.ecs_host_role.name}"
}

resource "aws_launch_configuration" "ecs" {
  name = "ECS ${aws_ecs_cluster.hazard.name}"
  image_id = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.ecs.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  key_name = "${aws_key_pair.acts-human.key_name}"
  associate_public_ip_address = true
  user_data = "#!/bin/bash\necho ECS_CLUSTER='${aws_ecs_cluster.hazard.name}' > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "ecs-cluster" {
  availability_zones = ["${var.availability_zone}"]
  name = "ECS ${aws_ecs_cluster.hazard.name}"
  min_size = "${var.autoscale_min}"
  max_size = "${var.autoscale_max}"
  desired_capacity = "${var.autoscale_desired}"
  health_check_type = "EC2"
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  vpc_zone_identifier = ["${aws_subnet.hazard.id}"]
}

