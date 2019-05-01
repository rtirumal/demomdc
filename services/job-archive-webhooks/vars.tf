# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
}

variable "terraform_state_aws_region" {
  description = "This value is intended to be inherited from the account.tfvars file in the inventory repo"
}

variable "terraform_state_s3_bucket" { 
  description = "This value is intended to be inherited from the account.tfvars file in the inventory repo"
}

variable "vpc_name" {
  description = "VPC name. Used in state file lookup. Usually inherited from env.tfvars file."
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue. An integer from 0 to 43200 (12 hours)"
  default = 30    # 30 Seconds
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days)"
  default = 345600  # 4 Days 
}

variable "max_message_size" {
  description = "limit of how many bytes a message can contain before Amazon SQS rejects it. An integer from 1024 bytes (1 KiB) up to 262144 bytes (256 KiB)"
  default = 262144  # 256 KiB 
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed. An integer from 0 to 900 (15 minutes)"
  default = 0       # 0 Seconds
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. An integer from 0 to 20 (seconds)"
  default = 0       # 0 Seconds
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue"
  default = false
}

variable "dead_letter_queue" {
  description = "Set to true to enable a dead letter queue. Messages that cannot be processed/consumed successfully will be sent to a second queue so you can set aside these messages and analyze what went wrong."
  default     = false
}

variable "max_receive_count" {
  description = "The maximum number of times that a message can be received by consumers. When this value is exceeded for a message the message will be automatically sent to the Dead Letter Queue. Only used if var.dead_letter_queue is true."
  default     = 3
}

variable "service_name" {
  description = "The Name of the service (without environment designation). Also used to create the Name tag of all service resources in this module."
  default     = "job-archive-webhooks"
}


variable "service_environment" {
  description = "Valid values for this variable are 'stage' or 'prod'. Also used to construct Name of any service resources in this package."
  default     = "stage"
}

variable "custom_tags" {
  description = "Optional mapping of tags to assign to the SQS Queue"
  type        = "map"
  default     = {}
}
