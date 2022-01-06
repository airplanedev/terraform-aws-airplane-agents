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
  type = string
  description = "ARN of API Token stored in AWS secret. Either this or API Token must be set."
  default = ""
}

variable "api_token_secret_kms_key_arn" {
  type = string
  description = "ARN of customer-managed KMS key, if any, used to encrypt API Token Secret."
  default = ""
}

variable "cluster_arn" {
  type = string
  description = "Your ECS cluster ARN. Leave blank to create a new cluster."
  default = ""
}

variable "agent_labels" {
  type        = map(string)
  description = "Map of label key/values to attach to agents. Labels can be used to constrain where tasks execute."
  default     = {ecs: "true"}
}

variable "service_name" {
  type = string
  description = "Name to assign to ECS service"
  default = "airplane-agent"
}

variable "subnet_ids" {
  type = list(string)
  description = "List of subnet IDs for ECS service"
  default = []
}