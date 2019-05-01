# sg-office-access

This directory creates a security group inside of your VPC.  This security group provides ingress only access from all magento offices and vpn connections, including the transit vpcs, over the ports  specified in the ports variable, passed in from an inventory.  The intention of this package is to be a centrally managed security group definition that can be easily managed any time a change occurs to any egress office cidr ranges.  The expectation is that if a VPC requires office access an inventory pointing to this package will be created for the VPC.  Then any resource that is created inside of the VPC can have this security group assigned to it to allow for the access needed.

This Security Group is not intended for inter-environment communication.  The sole purpose of this security group is for allowing access from magento offices.

The security group possesses a tag with timestamp() value, indicating the last time the security group was updated, allowing for quick identification of all sgs that need upating when a change does occur to office egress cidr ranges.

# Magento Office CIDR range change process

Any time the magento office cidr ranges change, remove or delete a cidr range the process is as follows:
- The package is updated to reflect the changes
- The INV of each VPC that uses this package is applied, picking up the changes and applying them to the target VPC

# Variables

| Variable Name | Variable Type | Supported Values | Default Value | Purpose |
| --- | ---| --- | --- | --- |
| aws_region | string | alphanumeric | NA | The region to launch resource inside of |
| aws_account_id | string | alphanumeric | NA | The Account ID this package is intended for |
| vpc_name | string | Alphanumeric | NA | The friendly name of the vpc used for prepending resource names and identifying remote state s3 object paths |
| vpc_terraform_state_aws_region | string | Alphanumeric | NA | The region in which the target VPCs remote state files are stored inside of S3 |
| vpc_terraform_state_s3_bucket | string | Alphanumeric | NA | The bucket in which the target VPCs remote state files are stored inside of S3 |
| vpc_terraform_state_s3_key | string | Alphanumeric | NA | The S3 key in which the target VPCs remote state file resides |
| ports | string | numeric | NA | All ports that you want to allow access over from the offices.  examples: 22, 80, 443, 8080 |


# TO DO

- After the major CIDR range change in January 2018 occurs, and we have verified all functionality, remove the security group rules that are "old"
