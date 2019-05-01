# Job Archive Data Package

> This package creates the resources needed to deploy Job Archive's Data component.

## Usage

At the moment, this package only creates a master KMS key for Job Archive Data.
This KMS key is used by Job Archive Aurora to encrypt database connection details stored in AWS Parameter Store (SSM).

Future iterations will feature additional resources.

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
    source = "git::ssh://git@github.com/magento/pkg-devops.git//services/job-archive-data?ref=1.0.0" # Make sure to update the release version
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
service_environment = "stage"
cmk_administrator_iam_arns = ["arn:aws:iam::981263594894:user/exampleuser_0"]
cmk_user_iam_arns = [
    "arn:aws:iam::981263594894:user/example_user_0",
    "arn:aws:iam::981263594894:user/example_user_1",
    "arn:aws:iam::981263594894:role/example_role"
  ]
```
