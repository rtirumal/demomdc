# THIS PACKAGE IS IN ALPHA


# Testing-Service Agent Image Build

Terraform package for the M2 Testing Service V2 agent image codebuild


# Manual Pre-requisites
- You must set your GITHUB OAUTH Environment Variable on the system executing this terraform code before running this package, otherwise authentication with github will fail during apply.

# Variables

| Variable Name | Variable Type | Supported Values | Default Value | Purpose |
| --- | ---| --- | --- | --- |
| aws_account_id | string | alphanumeric | |  |
| aws_region | string | alphanumeric | | The region to launch resource inside of |
| env_name | string | dev, qa, int, stage, prod | | Used for including in names of resources to identify the environment |
| service_name | string |  alphanumeric | | The name of the service |
| service_role | string |  alphanumeric | | The role of the service (example: master or agent) |
| acct_level_resources_s3_bucket | string | alphanumeric | | Account level S3 remote state bucket name | 
| acct_level_resources_s3_key | string | alphanumeric | | Account level S3 remote state S3 key path |  
| acct_level_resources_region | string | alphanumeric | | Account level remote state region |
| github_org | string | alphanumeric | | Github Org where the code resides |
| github_repo | string | alphanumeric | | Github Repo where the code resides |
| github_branch | string | alphanumeric | | Github Branch where the code resides |
| php_version_full | string | semantic version | | Full PHP version (example: 7.2.15) |
| php_version_short | numeric | (0-9)(0-9) | | Short PHP version (example: 72) |

# To Do
