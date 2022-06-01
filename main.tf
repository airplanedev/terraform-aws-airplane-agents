data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "cluster" {
  name = "airplane-ecs-cluster"
  capacity_providers = ["FARGATE"]
  count = var.cluster_arn == "" ? 1 : 0
}

data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

module "agent_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "airplane-agent"
  description = "Security group for Airplane agent"
  vpc_id      = data.aws_subnet.selected.vpc_id

  egress_rules = ["all-all"]

  tags = var.tags
}

resource "aws_iam_policy" "default_run_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = join(":", ["arn:aws:secretsmanager", data.aws_region.current.name, data.aws_caller_identity.current.account_id, "secret:airplane/*"])
        Effect = "Allow"
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role" "default_run_role" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.default_run_policy.arn
  ]

  tags = var.tags
}

resource "aws_iam_role" "agent_role" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
  inline_policy {
    name = "airplane-agent-policy"
    policy = jsonencode({
      Statement = concat([
        {
          Action = [
            "ecs:DescribeTasks",
            "ecs:RegisterTaskDefinition",
            "ecs:DeregisterTaskDefinition",
            "ecs:RunTask",
            "ecs:StopTask",
            "ecs:TagResource",
            "iam:PassRole",
            "logs:GetLogEvents",
          ],
          Resource = "*"
          Effect = "Allow"
        },
        {
          Action = [
            "secretsmanager:CreateSecret",
            "secretsmanager:DeleteSecret",
            "secretsmanager:DescribeSecret",
            "secretsmanager:GetSecretValue",
            "secretsmanager:TagResource",
          ]
          Resource = join(":", ["arn:aws:secretsmanager", data.aws_region.current.name, data.aws_caller_identity.current.account_id, "secret:airplane/*"])
          Effect = "Allow"
        },
      ], 
      var.api_token_secret_arn == "" ? [] : [{
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.api_token_secret_arn
        Effect = "Allow"
      }], 
      var.api_token_secret_kms_key_arn == "" ? [] : [{
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.api_token_secret_kms_key_arn
        Effect = "Allow"
      }])
    })
  }

  tags = var.tags
}

resource "aws_iam_role" "agent_execution_role" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = [
          "sts:AssumeRole"
        ]
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
  inline_policy {
    name = "airplane-agent-policy"
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Resource = "*"
          Effect = "Allow"
        }
      ]
    })
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "agent_task_def" {
  family = "airplane-agent-task-def"
  container_definitions = jsonencode([
    {
      name = "airplane-agent"
      image = "airplanedev/agent:1"
      environment = [
        {name = "AP_API_HOST", value = var.api_host},
        {name = "AP_API_TOKEN", value = var.api_token},
        {name = "AP_API_TOKEN_SECRET_ARN", value = var.api_token_secret_arn},
        {name = "AP_AWS_REGION", value = data.aws_region.current.name},
        {name = "AP_AUTO_UPGRADE", value = "true"},
        {name = "AP_DRIVER", value = "ecs"},
        {name = "AP_ECS_CLUSTER", value = var.cluster_arn == "" ? aws_ecs_cluster.cluster[0].arn : var.cluster_arn},
        {name = "AP_ECS_EXECUTION_ROLE", value = aws_iam_role.default_run_role.arn},
        {name = "AP_ECS_LOG_GROUP", value = aws_cloudwatch_log_group.run_log_group.name},
        {name = "AP_ECS_SECURITY_GROUPS", value = module.agent_security_group.security_group_id},
        {name = "AP_ECS_SUBNETS", value = join(",", var.subnet_ids)},
        {name = "AP_LABELS", value = join(",", [for key, value in var.agent_labels : "${key}:${value}"])}, 
        {name = "AP_PARALLELISM", value = "50"},
        {name = "AP_TEAM_ID", value = var.team_id},
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region" = data.aws_region.current.name
          "awslogs-group" = aws_cloudwatch_log_group.agent_log_group.name
          "awslogs-stream-prefix" = "agent"
        }
      }
    }
  ])
  cpu = var.agent_cpu
  memory = var.agent_mem
  network_mode = "awsvpc"
  task_role_arn = aws_iam_role.agent_role.arn
  execution_role_arn = aws_iam_role.agent_execution_role.arn
  runtime_platform {
    cpu_architecture = "X86_64"
    operating_system_family = "LINUX"
  }
  requires_compatibilities = ["FARGATE"]

  tags = var.tags
}

resource "aws_ecs_service" "agent_service" {
  name = var.service_name
  cluster = var.cluster_arn == "" ? aws_ecs_cluster.cluster[0].arn : var.cluster_arn
  desired_count = var.num_agents
  launch_type = "FARGATE"
  network_configuration {
    assign_public_ip = true
    security_groups = [module.agent_security_group.security_group_id]
    subnets = var.subnet_ids
  }
  task_definition = aws_ecs_task_definition.agent_task_def.arn

  propagate_tags = "SERVICE"
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "agent_log_group" {
  name_prefix = "/airplane/agents"

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "run_log_group" {
  name_prefix = "/airplane/runs"

  tags = var.tags
}
