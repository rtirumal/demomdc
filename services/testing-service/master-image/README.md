# THIS PACKAGE IS IN ALPHA


# Testing-Service Master Image Build

Terraform package for the M2 Testing Service V2 master image build pipeline


# Manual Pre-requisites
- You must set your GITHUB OAUTH Environment Variable on the system executing this terraform code before running this package, otherwise authentication with github will fail during apply.

# Variables

| Variable Name | Variable Type | Supported Values | Default Value | Purpose |
| --- | ---| --- | --- | --- |
| acct_name | string | Alphanumeric | NA | Used for prepending resource names |
| aws_acct_id | string | Alphanumeric | NA |  |
| aws_region | string | alphanumeric | NA | The region to launch resource inside of |
| vpc_name | string | Alphanumeric | NA | The friendly name of the vpc used for prepending resource names |
| vpc_id | alphanumeric | Alphanumeric | NA | The ID of the VPC |
| env_name | string | dev, qa, int, stage, prod | NA | Used for including in names of resources to identify the environment |
| service_name | string |  alphanumeric|   | The name of the service |
| service_role | string |  alphanumeric|   | The role of the service (example: master or agent)|
| github_owner | string | NA |  | Github Org where the code resides |
| github_repo | string | NA | | Github Repo where the code resides |
| github_branch | string | NA | | Github Branch where the code resides  |
| master_ecr_repo | string | NA | | The Github repo that possesses the master docker image definition  |

# To Do
