
resource "aws_cloudwatch_log_group" "ecs_scheduled_tasks" {
  name              = "/ecs-scheduled-tasks/kurakichi"
  retention_in_days = 180
}

resource "aws_ecs_task_definition" "kurakichi_batch" {
  family                   = "batch"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./batch_def.json")
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

module "ecs_events_role" {
  source     = "../iam"
  name       = "ecs-events"
  identifier = "events.amazonaws.com"
  policy     = data.aws_iam_policy.ecs_events_role_policy.policy
}

data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_cloudwatch_event_rule" "kurakichi_batch" {
  name                = "kurakichi-batch"
  description         = "くらきちテストバッチ"
  schedule_expression = "cron(*/2 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "kurakichi_batch" {
  target_id = "kurakichi-batch"
  rule      = aws_cloudwatch_event_rule.kurakichi_batch.name
  role_arn  = module.ecs_events_role.iam_role_arn
  arn       = aws_ecs_cluster.kurakichi.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    platform_version    = "1.3.0"
    task_definition_arn = aws_ecs_task_definition.kurakichi_batch.arn

    network_configuration {
      assign_public_ip = "false"
      subnets          = [var.private_subnet_0.id]
    }
  }
}
