# Build Info API Service

The build-info-api server is an AWS Lambda based application that is deployed using this terraform package and also an application based on serverless framework. Please review the [build-info-api](https://github.com/magento/build-info-api) serverless application repository.

This package is intended to create AWS resources for the [Build Info API](https://github.com/magento/build-info-api) application that we would like to manage in terraform instead of serverless YAML. The referenced application, built using Serverless Framework, relies on these resources for its deployment on AWS as an AWS Lambda Function. It is designed to deploy the lambda functions in a VPC. It relies on a VPC and VPC security group.

When the lambda executes it will create an ENI in the VPC that which has a security group attached. That security group is defined here.

## Resources

This repository currently allows the following resources to be created:

- Security Group
  - Ingress Rule:
    - This ingress rule allows connections from Magento Offices (Austin, LA and Barcelona) to AWS Lambda Endpoint.
    - CIDR Blocks were allowed according to our [Confluence page](https://wiki.corp.magento.com/pages/viewpage.action?spaceKey=SUP&title=List+of+Magento%27s+Dedicated+IPs).
  - Egress Rule:
    - This rule allows 443 egress to anywhere (including AWS DynamoDB endpoint).
    - This port is set as default on [Serverless Configuration](https://github.com/magento/build-info-api) of Build Info API. 
    - If this default port is changed, please update this Security Group Rule and redeploy.

## Future Work

- Migrate configuration of DynamoDB Database and Tables from [Serverless Configuration](https://github.com/magento/build-info-api) to Terragrunt.
- Ensure Lambda functions are accessing DynamoDB over the private endpoint created in their application VPC. For this we might need to adjust the security group rules. (See https://www.terraform.io/docs/providers/aws/r/security_group_rule.html#usage-with-prefix-list-ids)

## How to use this package

Infrastructure package modules such as this are used to create real resources in inventory repos. This package was designed to be deployed in [inv-aws-devops-core](https://github.com/magento/inv-aws-devops-core/tree/master/prod/us-east-1). Please see the README in that repo for additional usage instructions.
