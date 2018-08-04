provider "aws" {
  region = "${var.AWS_REGION}"
  version = "~> 1.30"
}

provider "template" {
  version = "~> 1.0"
  alias = "default"
}

module "base_vpc" {
  source             = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name               = "base_vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${var.AWS_REGION}a", "${var.AWS_REGION}b"]
  private_subnets    = ["${split(",", var.CIDR_PRIVATE)}"]
  public_subnets     = ["${split(",", var.CIDR_PUBLIC)}"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "Allow traffic for ecs"
  vpc_id      = "${module.base_vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.CIDR_PUBLIC)}"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${split(",", var.CIDR_PRIVATE)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Allow traffic for alb"
  vpc_id      = "${module.base_vpc.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "fargate" {
  name = "hazard"
}

resource "aws_alb" "hazard" {
  name = "hazard-alb"
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

output "alb_dns_name" {
  value = "${aws_alb.hazard.dns_name}"
}

resource "aws_cloudwatch_log_group" "hazard" {
  name = "/ecs/hazard"
  retention_in_days = 30
}
