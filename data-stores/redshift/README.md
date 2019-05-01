# Amazon Redshift Database

This module will create:

- Redshift Cluster
  - Redshift Cluster Parameter Group
  - Redshift Cluster Subnet Group
  - S3 bucket for redshift logs with bucket [policy](https://docs.aws.amazon.com/redshift/latest/mgmt/db-auditing.html#db-auditing-enable-logging)

## Terraform Inventory Requirements

This redshift package was created for use in the [inv-aws-devops-core inventory](https://www.github.com/magento/inv-aws-devops-core).

This package expects a VPC in a `vpc` folder in the same service environment.

For example:

``` text
prod
 └ _global
 └ us-east-1
    └ _global
    └ MyServiceEnvironmentWithRedshift
       └ vpc
       └ redshift
```

## More Information

This package is an inventory specific implementation of of these terraform modules:

- [redshift](https://github.com/magento/tf-aws-redshift)
- [s3-logs](https://github.com/magento/tf-aws-s3-logs/blob/master/README.md)

It was created as a package for this [`terragrunt`](https://github.com/gruntwork-io/terragrunt) inventory:

[inv-aws-devops-core inventory](https://www.github.com/magento/inv-aws-devops-core)
