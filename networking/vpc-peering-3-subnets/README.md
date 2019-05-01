# vpc-peering-3-subnets

Terraform package for establishing a VPC peering connection between two VPCs, in which 3 subnets need routes added between them, and these routes must be locked down to the specific subnets.  This Package will only work if you need exacly 3 subnets in your origin VPC to 3 subnets in your destination VPC.  If any other number of subnets need routes added this package will not work.

# Variables

| Variable Name | Variable Type | Supported Values | Default Value | Purpose |
| --- | ---| --- | --- | --- |
| aws_acct_id | string | alphanumeric | NA | The Account ID this package is intended for |
| aws_region | string | alphanumeric | NA | The region to launch resource inside of |
| target_alias | string |  alphanumeric |  Only needed when the destination VPC is in a separate account from the origin VPC.  The alias of the target VPC credentials definition |
| target_profile | string | NA |  | Only needed when the destination VPC is in a separate account from the origin VPC.  The profile name of the target VPC. in which the Route53 zone is hosted.  This value must match the profile name associated with the credentials for 
| origin_vpc_name | string | Alphanumeric | NA | The friendly name of the origin vpc used for prepending resource names |
| origin_vpc_id | string | Alphanumeric | NA | The ID of the origin VPC |
| origin_subnet_cidr_blocks | list | Alphanumeric | NA | The list of origin vpc subnet cidr blocks public |
| origin_vpc_route_table1_id | string | Alphanumeric | NA | The route table id of the first origin vpc route table |
| origin_vpc_route_table2_id | string | Alphanumeric | NA | The route table id of the second origin vpc route table |
| origin_vpc_route_table3_id | string | Alphanumeric | NA | The route table id of the third origin vpc route table |
| destination_vpc_name | string | Alphanumeric | NA | The friendly name of the destination vpc used for prepending resource names |
| destination_vpc_id | string | Alphanumeric | NA | The ID of the destination VPC |
| destination_subnet_cidr_blocks | list | Alphanumeric | NA | The list of destination vpc subnet cidr blocks public |
| destination_vpc_route_table1_id | string | Alphanumeric | NA | The route table id of the first destination vpc route table |
| destination_vpc_route_table2_id | string | Alphanumeric | NA | The route table id of the second destination vpc route table |
| destination_vpc_route_table3_id | string | Alphanumeric | NA | The route table id of the third destination vpc route table |
| custom_tags | map | Alphanumeric | NA | Map of additional tags to add to the peering connection resource |
