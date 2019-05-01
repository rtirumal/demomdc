# VPC Interface Endpoint Package

- This package is intended to be deployed in `inv-aws-devops-core` inventory.
- It ONLY supports VPC endpoints of type `Interface`
- It is intended to be used in conjunction with the `vpc_app` package.
  - It creates elastic network interfaces for the endpoint __in every private app subnet__ of the VPC.
