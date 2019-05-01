variable "aws_account_id" {
  description = "The AWS account id where the resources will be created"
}

variable "bucket_name" {
  description = "name of the s3 bucket to be created. i.e. myapp-prod-logs"
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. We recommend log-delivery-write for compatibility with AWS services"
  default     = "log-delivery-write"
}

variable "policy" {
  description = "A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy."
  default     = ""
}

variable "prefix" {
  description = "(Optional) Key prefix. identifies one or more files to which the rule applies (e.g. logs/). Empty path means all files"
  default     = "logs/"
}

variable "aws_region" {
  description = "(Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee."
  default     = ""
}

variable "force_destroy" {
  description = "(Optional) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = "false"
}

variable "lifecycle_rule_enabled" {
  description = "(Optional) enable lifecycle events on this bucket"
  default     = "true"
}

variable "versioning_enabled" {
  description = "(Optional) Enable or disable s3 bucket versioning"
  default     = "false"
}

variable "noncurrent_version_standard_transition_days" {
  description = "(Optional) Specifies when noncurrent object versions transitions"
  default     = "30"
}

variable "noncurrent_version_glacier_transition_days" {
  description = "(Optional) Specifies when noncurrent object versions transitions"
  default     = "60"
}

variable "noncurrent_version_expiration_days" {
  description = "(Optional) Specifies when noncurrent object versions expire"
  default     = "120"
}

variable "standard_transition_days" {
  description = "Number of days after which item is moved to the infrequent access tier"
  default     = "30"
}

variable "glacier_transition_days" {
  description = "Number of days after which item is moved to the glacier storage tier"
  default     = "60"
}

variable "expiration_days" {
  description = "Number of days after which item is permanantly deleted"
  default     = "365"
}

variable "tags" {
  type = "map"

  default = {
    "Adobe.Environment"        = "Dev"
    "Adobe.DataClassification" = "Internal"
  }
}
