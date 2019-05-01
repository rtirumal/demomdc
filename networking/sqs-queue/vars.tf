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

variable "name" { 
  description = "The name of the SQS Queue"
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

variable "custom_tags" {
  description = "Optional mapping of tags to assign to the SQS Queue"
  type        = "map"
  default     = {}
}
