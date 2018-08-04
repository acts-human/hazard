resource "aws_iam_role" "ecs_task_assume" {
  name = "ecs_task_assume"
  assume_role_policy = "${file("res/iam-role-ecs-task-assume.json")}"
}

resource "aws_iam_role_policy" "ecs_task_assume" {
  name = "ecs_task_assume"
  role = "${aws_iam_role.ecs_task_assume.id}"
  policy = "${file("res/iam-role-policy-ecs-task-assume.json")}"
}

