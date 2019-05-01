# fargateapp

Terraform package for the fargate-CD-pipeline.

# Variables

| Variable Name                         | Variable Type | Supported Values                                                                   | Default Value | Purpose                                                                                                            |
| ------------------------------------- | ------------- | ---------------------------------------------------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------ |
| aws_region                            | string        | alphanumeric                                                                       | NA            | The region to launch resource inside of                                                                            |
| vpc_name                              | string        | Alphanumeric                                                                       | NA            | The friendly name of the vpc used for prepending resource names                                                    |
| env_name                              | string        | dev, qa, int, stage, prod                                                          | NA            | Used for including in names of resources to identify the environment                                               |
| service_name                          | string        | alphanumeric                                                                       |               | The name of the service                                                                                            |
| container_port                        | numeric       | NA                                                                                 |               | Port to use for the service container (For fargate both host and container ports are required and must match)      |
| host_port                             | numeric       | NA                                                                                 |               | Port to use for the service container host (For fargate both host and container ports are required and must match) |
| task_protocol                         | alpha         | NA                                                                                 |               | Protocol to use for the service container                                                                          |
| task_cpu                              | numeric       | see below                                                                          |               | The number of cpu units used by the task.                                                                          |
| task_memory                           | numeric       | see below                                                                          |               | The amount (in MiB) of memory used by the task                                                                     |
| 256 (.25 vCPU)                        |               | 512 (0.5GB), 1024 (1GB), 2048 (2GB)                                                |               |                                                                                                                    |
| 512 (.5 vCPU)                         |               | 1024 (1GB), 2048 (2GB), 3072 (3GB), 4096 (4GB)                                     |               |                                                                                                                    |
| 1024 (1 vCPU)                         |               | 2048 (2GB), 3072 (3GB), 4096 (4GB), 5120 (5GB), 6144 (6GB), 7168 (7GB), 8192 (8GB) |               |                                                                                                                    |
| 2048 (2 vCPU)                         |               | Between 4096 (4GB) and 16384 (16GB) in increments of 1024 (1GB)                    |               |                                                                                                                    |
| 4096 (4 vCPU)                         |               | Between 8192 (8GB) and 30720 (30GB) in increments of 1024 (1GB)                    |               |                                                                                                                    |
| service_desired_count                 | numeric       | NA                                                                                 | NA            | The number of instances of the task definition to place and keep running                                           |
| github_owner                          | string        |                                                                                    | NA            | The owner/organization. For us, this is most likely Magento                                                        |
| github_repo                           | string        | ~"engcom-githubapp-m2-functional-ce-pr"                                            | NA            | Name of the github repo.                                                                                           |
| github_branch                         | string        | ~"demo2"                                                                           | NA            | Branch from the repo.                                                                                              |
| zone_id                               | string        | ~"ZMG9UTMVU1VN6"                                                                   | NA            | DNS zone ID where this subdomain will get deployed.                                                                |
| public_access_enabled                 | Boolean       | true,false                                                                         | false         | Whether or not to allow the Public internet to hit the 443 hosted Port at the subdomain created..                  |
| register_service_enabled              | Boolean       | true, false                                                                        | false         | Whether or not to register the subdomain as an endpoint into Parameter Store                                       |
| allow_inbound_from_cidr_blocks        | list          |                                                                                    | N/A           | List of CIDR blocks to allow access to this fargateapp                                                             |
| allow_inbound_from_security_group_ids | list          |                                                                                    | N/A           | List of allowed Security groups that are allowed to reach the fargateapp                                           |


# Known Issues

Re-Apply to resolve this known issue. Fix planned.

```
Error: Error applying plan:

1 error(s) occurred:

* aws_ecs_service.fargateapp: 1 error(s) occurred:

* aws_ecs_service.fargateapp: InvalidParameterException: The target group with targetGroupArn arn:aws:elasticloadbalancing:us-east-1:981263594894:targetgroup/health-in-ce-stage/8ed4903d1e1a1c46 does not have an associated load balancer.
        status code: 400, request id: d8bc6b98-6147-11e9-9e59-b3282db00805 "health-in-ce-stage"

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
```