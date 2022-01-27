# terraform-aws-agents

This terraform module creates an ECS cluster running Airplane agents.

To get started, you'll need an `api_token` and your `team_id`.

Use this module in your Terraform configuration:

```hcl
module "airplane_agent" {
  source = "airplanedev/airplane-agents/aws"
  version = "~> 0.2.0"

  api_token = "YOUR_API_TOKEN"
  team_id = "YOUR_TEAM_ID"

  # Set which subnets agents should live in
  subnet_ids = ["subnet-000", "subnet-111"]

  # Optional: attach labels to agents for task constraints
  agent_labels = {
    vpc = "123"
    env = "test"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.22.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.agent_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.run_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.agent_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.agent_task_def](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.default_run_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.agent_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.agent_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.default_run_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_security_group.agent_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_team_id"></a> [team\_id](#input\_team\_id) | Airplane team ID - retrieve via `airplane auth info`. | `string` | n/a | yes |
| <a name="input_agent_labels"></a> [agent\_labels](#input\_agent\_labels) | Map of label key/values to attach to agents. Labels can be used to constrain where tasks execute. | `map(string)` | <pre>{<br>  "ecs": "true"<br>}</pre> | no |
| <a name="input_api_host"></a> [api\_host](#input\_api\_host) | For development purposes. | `string` | `"https://api.airplane.dev"` | no |
| <a name="input_api_token"></a> [api\_token](#input\_api\_token) | Airplane API key - generate one via `airplane apikeys create`. EIther this or API Token Secret must be set | `string` | `""` | no |
| <a name="input_api_token_secret_arn"></a> [api\_token\_secret\_arn](#input\_api\_token\_secret\_arn) | ARN of API Token stored in AWS secret. Either this or API Token must be set. | `string` | `""` | no |
| <a name="input_api_token_secret_kms_key_arn"></a> [api\_token\_secret\_kms\_key\_arn](#input\_api\_token\_secret\_kms\_key\_arn) | ARN of customer-managed KMS key, if any, used to encrypt API Token Secret. | `string` | `""` | no |
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | Your ECS cluster ARN. Leave blank to create a new cluster. | `string` | `""` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name to assign to ECS service | `string` | `"airplane-agent"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for ECS service | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | AWS tags to attach to resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to deploy to, should match subnet IDs | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
