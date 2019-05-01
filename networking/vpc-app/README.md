# VPC-APP

This directory creates a 3-Tier [Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc/) that can be used for either
production or non-production workloads.

* _*NOTE*_ This module is specifically designed to peer to another VPC with the module:

The resources that are created include:

1. The *VPC* itself.
2. *Subnets*, which are isolated subdivisions within the VPC. There are 3 "tiers" of subnets: public, private app, and
   private persistence.
3. *Route tables*, which provide routing rules for the subnets.
4. *Internet Gateways* to route traffic to the public Internet from public subnets.
5. *NAT Gateways* to route traffic to the public Internet from private subnets.
6. *Network ACLs* that control what traffic can go in and out of each subnet.

Under the hood, this is all implemented using Terraform modules from the Gruntwork
[module-vpc](https://github.com/gruntwork-io/module-vpc) repo.

## ! Things you should know

### Peering Connections

If the `num_availability_zones` variable in the mgmt VPC and the `num_availability_zones` variable in the app VPC don't match, there are problems with the routes that are created between the two VPCs as part of setting up VPC Peering if you are using the **[vpc-peering](../vpc-peering/README.md) module** to setup the peering connection. If your use case requires different numbers of Availability Zones for each of these VPCs, please let us know and we'll investigate further!

## Core concepts

To understand core concepts like what's a VPC, how subnets are configured, how network ACLs work, and more, see the
documentation in the [module-vpc](https://github.com/gruntwork-io/module-vpc) repo.

## VPC Design Notes

``` text
CIDR    Host Formula Available Hosts
/8      232-8 - 2   16,777,214
/9      232-9 - 2   8,388,606
/10     232-10 - 2  4,194,302
/11     232-11 - 2  2,097,150
/12     232-12 - 2  1,048,574
/13     232-13 - 2  524,286
/14     232-14 - 2  262,142
/15     232-15 - 2  131,070
/16     232-16 - 2  65,534
/17     232-17 - 2  32,766
/18     232-18 - 2  16,382
/19     232-19 - 2  8,190
/20     232-20 - 2  4,094
/21     232-21 - 2  2,046
/22     232-22 - 2  1,022
/23     232-23 - 2  510
/24     232-24 - 2  254
/25     232-25 - 2  126
/26     232-26 - 2  62
/27     232-27 - 2  30
/28     232-28 - 2  14
/29     232-29 - 2  6
/30     232-30 - 2  2
```