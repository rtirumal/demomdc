# THIS PACKAGE IS IN ALPHA

# Testing-Service

Terraform package for the m2 testing service

# Manual Pre-requisites
- You must set your GITHUB OAUTH Environment Variable on the system executing this terraform code before running this package, otherwise authentication with github will fail during apply.
- Manually create and populate the following parameter store entries:
    "/${var.vpc_name}/${var.service_name}/datadog/apikey"

# Post-Apply Manual Steps
- Populate the following Parameter Store values:
    aws_ssm_parameter.aws_jenkins_user_id
    aws_ssm_parameter.aws_jenkins_access_key
    aws_ssm_parameter.aws_jenkins_secret_key

# Variables

| Variable Name | Variable Type | Supported Values | Default Value | Purpose |
| --- | ---| --- | --- | --- |
| acct_name | string | Alphanumeric | NA | Used for prepending resource names |
| aws_acct_id | string | alphanumeric | NA | The Account ID this package is intended for |
| aws_region | string | alphanumeric | NA | The region to launch resource inside of |
| vpc_name | string | Alphanumeric | NA | The friendly name of the vpc used for prepending resource names |
| vpc_id | string | Alphanumeric | NA | The ID of the VPC |
| Public_subnets | string | Alphanumeric | NA | The public subnets for the Load Balancer |
| private_subnets | string | Alphanumeric | NA | The private subnets for the cluster/service to residfe in |
| env_name | string | dev, qa, int, stage, prod | NA | Used for including in names of resources to identify the environment |
| service_name | string |  alphanumeric|   | The name of the service |
| service_role | string |  alphanumeric|  master, build, agent | The name of the service role |
| container_port | numeric | NA |  | Port to use for the service container (For fargate both host and container ports are required and must match)|
| host_port | numeric | NA | | Port to use for the service container host (For fargate both host and container ports are required and must match)|
| protocol | alpha | NA | | Protocol to use for the service container |
| task_cpu | numeric | see below | | The number of cpu units used by the task. |
| task_memory | numeric | see below | | The amount (in MiB) of memory used by the task |
| 256 (.25 vCPU) | | 512 (0.5GB), 1024 (1GB), 2048 (2GB) | |  |
| 512 (.5 vCPU) | | 1024 (1GB), 2048 (2GB), 3072 (3GB), 4096 (4GB) | |  |
| 1024 (1 vCPU) | | 2048 (2GB), 3072 (3GB), 4096 (4GB), 5120 (5GB), 6144 (6GB), 7168 (7GB), 8192 (8GB) | |  |
| 2048 (2 vCPU)	| | Between 4096 (4GB) and 16384 (16GB) in increments of 1024 (1GB) | |  |
| 4096 (4 vCPU)	| | Between 8192 (8GB) and 30720 (30GB) in increments of 1024 (1GB) | |  |
| service_desired_count | numeric | NA | NA | The number of instances of the task definition to place and keep running |
| github_owner | alpha | NA | NA | Github Org |
| github_repo | alpha | NA | NA | Github Repo |
| github_branch | alpha | NA | NA | Github Branch |

# To Do