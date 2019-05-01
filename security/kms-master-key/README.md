# KMS Master Key

This Terraform Module creates a [Customer Master
Key (CMK)](http://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#master_keys) in [Amazon's Key Management
Service (KMS)](https://aws.amazon.com/kms/) as well as a [Key
Policy](http://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#key_permissions) that controls who has
access to the CMK. You can use this CMK to encrypt and decrypt small amounts of data, such as secrets that you store
in a config file.

You can use KMS via the AWS API, CLI, or, for a more streamlined experience, you can use
[gruntkms](https://github.com/gruntwork-io/gruntkms).

## Where to use this in your inventory

It depends on how your environments are separated and whether you want to share KMS keys between them.
A KMS key is technically a global iam resource in AWS (not regional).
You should at minimum use separate keys for your production and non-production environments.

* If you have a single account with multiple environments you could deploy this module to an environment folder.
  e.g. `prod/us-east-1/my-app-stage/kms-master-key`
* If prod and non-prod are separated by AWS accounts and there is only one application in the AWS account,
  then you could deploy this module to the  `_global` folder for the account. e.g. `prod/_global/kms-master-key`

## Core concepts

To understand core concepts like what is KMS, what is a Customer Master Key, and how to use them to encrypt and decrypt
data, see the [kms-master-key
module](https://github.com/gruntwork-io/module-security/tree/master/modules/kms-master-key) and
[gruntkms](https://github.com/gruntwork-io/gruntkms).

### How to rotate your key

[AWS docs: Rotate KMS key](https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html#rotate-keys-how-it-works)

ToDo: Add documentation on how to rotate keys when they are in use for common services such as RDS and disk encryption.
