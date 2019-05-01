# ---------------------------------------------------------------------------------------------------------------------
# GENERAL
# ---------------------------------------------------------------------------------------------------------------------


# variable "acct_name" {
#   description = "Account Name"
#   default     = ""
# }

variable "aws_account_id" {
  description = "AWS Account ID"
  default     = ""
}

variable "aws_region" {
  description = "region"
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID"
  default     = ""
}

variable "vpc_name" {
  description = "VPC Name"
  default     = ""
}

variable "public_subnets" {
  description = "Public Subnets"
  default     = []
}

variable "private_subnets" {
  description = "Private Subnets"
  default     = []
}

variable "private_subnets_string" {
  description = "Private Subnets"
}

variable "env_name" {
  description = "The Environment Name to deploy the service into.  qa, or dev, or stage or prod for, example"
  default     = ""
}

variable "service_name" {
  description = "Service Name"
  default     = ""
}

variable "service_role" {
  description = "Service Role"
  default     = ""
}

variable "testing_service_ldap_username" {
  description = "Jenkins API username"
  default     = ""
}

variable "testing_service_jenkins_job_url" {
  description = "URL to Jenkins public PR job"
  default     = ""
}

variable "acct_level_resources_s3_bucket" {
  description = "acct_level_resources_s3_bucket"
  default     = ""
}

variable "acct_level_resources_s3_key" {
  description = "acct_level_resources_s3_key"
  default     = ""
}

variable "acct_level_resources_region" {
  description = "acct_level_resources_s3_region"
  default     = ""
}

variable "jenkins_aws_user_id" {
  description = "jenkins_aws_user_id"
  default     = ""
}

variable "sg_office_access_terraform_state_aws_region" {
  description = "vpc_terraform_state_aws_region"
  default     = ""
}

variable "sg_office_access_terraform_state_s3_bucket" {
  description = "vpc_terraform_state_s3_bucket"
  default     = ""
}

variable "sg_office_access_terraform_state_s3_key" {
  description = "vpc_terraform_state_s3_key"
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

variable "service_desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  default     = ""
}

variable "master_ecr_repo" {
  description = "Jenkins Master ECR Repo"
  default     = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# ECS TASK
# ---------------------------------------------------------------------------------------------------------------------

variable "container_port" {
  description = "Container Port to open up for the container via the task definition"
  default     = ""
}

variable "host_port" {
  description = "host Port to open up for the container via the task definition"
  default     = ""
}

variable "protocol" {
  description = "Protocol to assign to prt communications with the contner via hte task definition"
  default     = ""
}

variable "task_memory" {
  description = "memory for the task"
  default     = ""
}

variable "task_cpu" {
  description = "cpu for the task"
  default     = ""
}


# ---------------------------------------------------------------------------------------------------------------------
# SQS
# ---------------------------------------------------------------------------------------------------------------------

variable "deadletter_delay_seconds" {
  description = "deadletter_delay_seconds"
}

variable "deadletter_max_message_size" {
  description = "deadletter_max_message_size"
}

variable "deadletter_message_retention_seconds" {
  description = "deadletter_message_retention_seconds"
}

variable "deadletter_receive_wait_time_seconds" {
  description = "deadletter_receive_wait_timeout_seconds"
}

variable "testreq_delay_seconds" {
  description = "testreq_delay_seconds"
}

variable "testreq_max_message_size" {
  description = "testreq_max_message_size"
}

variable "testreq_message_retention_seconds" {
  description = "testreq_message_retention_seconds"
}

variable "testreq_receive_wait_time_seconds" {
  description = "testreq_receive_wait_time_seconds"
}

variable "testreq_visibility_timeout_seconds" {
  description = "testreq_visibility_timeout_seconds"
}
