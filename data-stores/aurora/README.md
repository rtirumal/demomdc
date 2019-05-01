# Aurora DB Package

> This package creates an Amazon Relational Database Service (RDS) cluster that runs Amazon Aurora. The cluster is managed by AWS and automatically handles leader election, replication, failover, backups, patching, and encryption. This package also handles automatic master password generation for the database master user and stores relevant configuration details in AWS System Manager's Parameter Store (SSM).

## Usage

### Instantiation

Below is an example `terraform.tfvars` file you can use to instantiate this package in an inventory.

``` HCL
# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------
terragrunt = {
  # Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
  # working directory, into a temporary folder, and execute your Terraform commands in that folder.
  terraform {
    source =  "git@github.com:magento/pkg-devops.git//data-stores/aurora?ref=1.0.0" # Make sure to update the release version
  }

  # Include all settings from the root terraform.tfvars file
  include = {
    path = "${find_in_parent_folders()}"
  }

  # When using the terragrunt xxx-all commands (e.g., apply-all, plan-all), deploy these dependencies before this module
  dependencies = {
    paths = ["../vpc"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------
# aws_account_id                  ** Variables from account.tfvars: **
# terraform_state_s3_bucket
# terraform_state_aws_region
# aws_region                      ** Variables from region.tfvars: **
# vpc_name                        ** Variables from env.tfvars: **

service_name = "example-service"
component_name = "optional"
service_environment = "stage"     # valid values are 'stage' or 'prod'
name = "example-cluster-name"
db_name = "example-db-name"
engine = "aurora-postgresql"      # one of aurora or aurora-postgresql
engine_version = "10.6"           # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Updates.20180305.html
port = "5432"
instance_count = 1                # number of replicas
instance_type = "db.r4.large"     # http://docs.amazonaws.cn/en_us/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
master_username = "example-root-username"
kms_key_arn = "arn:aws:kms:us-east-1:000000000000:key/a0a0a0a0-0000-0000-a0a0-a0a0a0a0a0a0"

# Add tags that will be added to all taggable resources in this package
custom_tags = {
  # "Adobe.ArchPath"      = "NeedValue"
    "Adobe.Environment"   = "Stage"
  # "Adobe.Owner"         = "NeedValue"
  # "Adobe.CostCenter"    = "NeedValue"
  # "Adobe.SKMSServiceId" = "Need Value"
}
```

This package is based on [Gruntwork's Aurora module](https://github.com/gruntwork-io/module-data-storage/tree/master/modules/aurora). See the [Aurora example](/examples/aurora) for more examples.

### Connecting to the database

This package assumes it is used in conjunction with the [`vpc-app` module](https://github.com/gruntwork-io/module-vpc/tree/master/modules/vpc-app). Database instances are created inside the "Private/Persistence Subnets" and are allowed access only from the "Private/App Subnets". Make sure you place your database
client applications in the "Private/App Subnets" and the VPC's default security group. Additionally, you might also need to create security groups for your client applications that allow inbound/outbound access to the dabatase cluster's CIDR blocks and port.

#### Connection details

This module provides the connection details as [Terraform output variables](https://www.terraform.io/intro/getting-started/outputs.html).
Details are also stored as SSM Parameters allowing the values to be dynamically retrived by client applications:

1. **Cluster endpoint**: The endpoint for the whole cluster. You should always use this URL for writes, as it points to
   the primary.
1. **Instance endpoints**: A comma-separated list of all DB instance URLs in the cluster, including the primary and all
   read replicas. Use these URLs for reads (see "How do you scale this DB?" below).
1. **Port**: The port to use to connect to the endpoints above.

For more info, see [Aurora
endpoints](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Aurora.html#Aurora.Overview.Endpoints).

You can programmatically extract these variables in your Terraform templates and pass them to other resources (e.g.
pass them to User Data in your EC2 instances). You'll also see the variables at the end of each `terraform apply` call
or if you run `terraform output`.

### Scaling

* **Storage**: Aurora manages storage for you, automatically growing cluster volume in 10GB increments up to 64TB.
* **Vertical scaling**: To scale vertically (i.e. bigger DB instances with more CPU and RAM), use the `instance_type`
  input variable. For a list of AWS RDS server types, see [Aurora Pricing](http://aws.amazon.com/rds/aurora/pricing/).
* **Horizontal scaling**: To scale horizontally, you can add more replicas using the `instance_count` input variable,
  and Aurora will automatically deploy the new instances, sync them to the master, and make them available as read
  replicas.

For more info, see [Managing an Amazon Aurora DB
Cluster](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Aurora.Managing.html).
