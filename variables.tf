// Required variables.
variable "team_id" {
  type        = string
  description = "Airplane team ID - retrieve via `airplane auth info`."
}

// Optional variables.
variable "api_host" {
  type        = string
  description = "For development purposes."
  default     = "https://api.airplane.dev"
}

variable "api_token" {
  type        = string
  description = "Airplane API key - generate one via `airplane apikeys create`. EIther this or API Token Secret must be set"
  sensitive   = true
  default     = ""
}

variable "api_token_secret_arn" {
  type        = string
  description = "ARN of API Token stored in AWS secret. Either this or API Token must be set."
  default     = ""
}

variable "api_token_secret_kms_key_arn" {
  type        = string
  description = "ARN of customer-managed KMS key, if any, used to encrypt API Token Secret."
  default     = ""
}

variable "cluster_arn" {
  type        = string
  description = "Your ECS cluster ARN. Leave blank to create a new cluster."
  default     = ""
}

variable "agent_labels" {
  type        = map(string)
  description = "Map of label key/values to attach to agents. Labels can be used to constrain where tasks execute."
  default     = { ecs : "true" }
}

variable "agent_cpu" {
  type        = number
  description = "CPU per agent, in vCPU units"
  default     = 256
}

variable "agent_mem" {
  type        = number
  description = "Memory per agent, in megabytes"
  default     = 512
}

variable "default_task_cpu" {
  type        = string
  description = "Default CPU for tasks, in millicores (e.g. 500m or 1000m)"
  default     = "1000m"
}

variable "default_task_memory" {
  type        = string
  description = "Default memory for tasks (e.g. 500Mi or 2Gi)"
  default     = "1Gi"
}

variable "num_agents" {
  type        = number
  description = "Number of agent instances to run"
  default     = 3
}

variable "service_name" {
  type        = string
  description = "Name to assign to ECS service"
  default     = "airplane-agent"
}

variable "tags" {
  type        = map(string)
  description = "AWS tags to attach to resources"
  default     = {}
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS service. Will create a security group for each one."
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to use. If not set, a new security group is created for each of the provided subnet IDs."
  default     = []
}
