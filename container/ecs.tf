
variable "vpc" {}
variable "private_subnet_0" {}
variable "private_subnet_1" {}
variable "lb_target_group" {}

resource "aws_ecs_cluster" "kurakichi" {
  name = "kurakichi"
}

resource "aws_ecs_task_definition" "kurakichi" {
  family                   = "kurakichi"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./ecs_def.json")
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

resource "aws_ecs_service" "kurakichi" {
  name                              = "kurakichi"
  cluster                           = aws_ecs_cluster.kurakichi.arn
  task_definition                   = aws_ecs_task_definition.kurakichi.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  platform_version                  = "1.3.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.nginx_sg.security_group_id]

    subnets = [
      var.private_subnet_0.id,
      var.private_subnet_1.id,
    ]
  }

  load_balancer {
    target_group_arn = var.lb_target_group.arn
    container_name   = "kurakichi"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

module "nginx_sg" {
  source      = "../sg"
  name        = "nginx-sg"
  vpc_id      = var.vpc.id
  port        = 80
  cidr_blocks = [var.vpc.cidr_block]
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/kurakichi"
  retention_in_days = 180
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source     = "../iam"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}
