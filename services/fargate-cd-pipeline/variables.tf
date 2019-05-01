# ---------------------------------------------------------------------------------------------------------------------
# INHERITED PARAMETERS
# These variables are required. They are intended to be passed in via global vars files for the account.
# ---------------------------------------------------------------------------------------------------------------------
variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources. Intended to be inherited from account.tfvars"
}

variable "terraform_state_aws_region" {
  description = "This value is intended to be inherited from the account.tfvars file in the inventory repo"
}

variable "terraform_state_s3_bucket" {
  description = "This value is intended to be inherited from the account.tfvars file in the inventory repo"
}

variable "aws_region" {
  description = "The AWS region in which all resources will be created. Intended to be inherited from region.tfvars"
}

######################################
# General
######################################

variable "acct_name" {
  description = "Account Name"
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

variable "register_service_enabled" {
  description = "Whether to enable registration of the endpoint into SSM. true/false"
  default     = false
}

variable "allowed_s3_buckets" {
  description = "An optional list of existing s3 bucket arns the fargate app will be given read and write access to."
  type        = "list"
  default     = []
}

variable "custom_tags" {
  description = "A map of custom tags to apply to the fargate resources created with this package. The key is the tag name and the value is the tag value."
  type        = "map"
  default     = {}
}

################
# Networking
################

variable "public_access_enabled" {
  description = "Whether to enable public internet access. true/false"
  default     = false
}

variable "allow_inbound_from_cidr_blocks" {
  description = "The list of CIDR blocks for your Fargate service to allow inbound connections from"
  type        = "list"
}

variable "allow_inbound_from_security_group_ids" {
  description = "The list of security group ids that are allowed to send traffic to the Fargate service"
  type        = "list"
  default     = []
}

variable "protocol" {
  description = "The protocol for your Fargate service to allow inbound connections on. You can specify more protocols by adding an addtional scurity group rule and attaching it to the 'fargate_instance_security_group_id' output" #Should this be coming from the ECS task? 
}

#variable "from_port" {
#  description = "The start port for your Fargate service to allow inbound connections on. You can specify more port ranges by adding an addtional scurity group rule and attaching it to the 'fargate_instance_security_group_id' output"
#}

#variable "to_port" {
#  description = "The end port for your Fargate service to allow inbound connections on. You can specify more port ranges by adding an addtional scurity group rule and attaching it to the 'fargate_instance_security_group_id' output"
#}

# ALB Target Group Defaults
variable "alb_target_group_protocol" {
  description = "The network protocol to use for routing traffic from the ALB to the Targets. Must be one of HTTP or HTTPS. Note that if HTTPS is used, per https://goo.gl/NiOVx7, the ALB will use the security settings from ELBSecurityPolicy2015-05."
  default     = "HTTP"
}

######################################
# ECS Task
######################################
variable "task_image" {
  description = "Image for the container"
  default     = ""
}

variable "container_port" {
  description = "Container Port to open up for the container via the task definition"
  default     = ""
}

variable "host_port" {
  description = "host Port to open up for the container via the task definition"
  default     = ""
}

# This should be coming from the security group rule? 
#variable "protocol" {
#  description = "Protocol to assign to prt communications with the contner via hte task definition"
#  default     = ""
#}

variable "task_memory" {
  description = "memory for the task"
  default     = ""
}

variable "task_cpu" {
  description = "cpu for the task"
  default     = ""
}

######################################
# ECS Service
######################################
variable "service_desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  default     = ""
}

######################################
# ECS Service
######################################
variable "client_secret" {
  description = "Client Secret Variable"
  default     = ""
}

variable "client_id" {
  description = "Client ID Variable"
  default     = ""
}

######################################
# Codepipeline
######################################

variable "github_owner" {
  description = "Github Org"
  default     = ""
}

variable "github_repo" {
  description = "Github Repo"
  default     = ""
}

variable "github_branch" {
  description = "Github Branch"
  default     = ""
}

variable "fargateapp_ecr_repo" {
  description = "fargateapp ECR Repo"
  default     = ""
}

variable "github_fargateapp_build_loc" {
  description = "Github Repo for fargateapp Image Buikld Codebuild job to locate the buildspec"
  default     = ""
}

######################################
# Route53
######################################
variable "zone_id" {
  description = "The zone ID of the main domain for which the subdomains will be created. "

  #solutionascode.com. is default due to cert hardcoding at this time.
  default = "ZMG9UTMVU1VN6"
}
