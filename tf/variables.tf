variable "region" {
  description = "The AWS region."
  default = "us-west-2"
}

variable "availability_zone" {
  description = "The AWS availability zone inside the AWS region."
  default = "us-west-2a"
}

variable "autoscale_min" {
  default = "1"
  description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max" {
  default = "3"
  description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
  default = "2"
  description = "Desired autoscale (number of EC2)"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "amis" {
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
  default = {
    us-west-2 = "ami-f189d189"
  }
}

