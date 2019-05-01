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

variable "instance_type" {
  description = "The instance type to use for the Jenkins server (e.g. t2.medium)"
}

variable "ami" {
  description = "The ID of the AMI to run on the Jenkins server. This should be the AMI build from the Packer template at packer/jenkins-ubuntu.json."
}

variable "keypair_name" {
  description = "The name of a Key Pair that can be used to SSH to the Jenkins server. Leave blank if you don't want to enable Key Pair auth."
}

variable "vpc_name" {
  description = "The name of the VPC in which to deploy Jenkins"
}

variable "root_volume_size" {
  description = "The amount of disk space, in GB, to allocate for the root volume of this server. Note that all of Jenkins' data is stored on a separate EBS Volume (see var.jenkins_volume_size), so this root volume is primarily used for the OS, temp folders, apps, etc."
  default     = 100
}

variable "ebs_optimized" {
  default     = true
  description = "Is Jenkins EC2 instance ebs_optimized. true or false."
}

variable "jenkins_volume_size" {
  description = "The amount of disk space, in GB, to allocate for the EBS volume used by the Jenkins server."
}

variable "memory" {
  description = "The amount of memory to give Jenkins (e.g., 1g or 512m). Used for the -Xms and -Xmx settings."
}

variable "terraform_state_aws_region" {
  description = "The AWS region of the S3 bucket used to store Terraform remote state"
}

variable "terraform_state_s3_bucket" {
  description = "The name of the S3 bucket used to store Terraform remote state"
}

variable "tenancy" {
  description = "The tenancy of this server. Must be one of: default, dedicated, or host."
  default     = "default"
}

variable "hosted_zone_id" {
  description = "ID of the AWS Route53 hosted zone, not required if create_route53_entry var is set to false"
  default     = ""
}

variable "create_route53_entry" {
  description = "Boolean value to set dns entry or not, defaults to false"
  default     = false
}

variable "domain_name" {
  description = "The domain name for the DNS A record to add for Jenkins (e.g. jenkins.foo.com)."
  default     = ""
}

variable "acm_ssl_certificate_domain" {
  description = "The domain name used for an SSL certificate issued by the Amazon Certificate Manager (ACM)."
  default     = ""
}

variable "user_access_security_group_id" {
  description = "The security group id used to restrict incominng https and ssh access intended for user access to Jenkins server."
  default     = ""
}

variable "custom_tags" {
  description = "A list of custom tags to apply to Jenkins and all other resources."
  type        = "map"
  default     = {}
}

variable "num_days_after_which_archive_log_data" {
  description = "After this number of days, Jenkins ALB access logs should be transitioned from S3 to Glacier. Enter 0 to never archive log data."
  default     = 100
}

variable "num_days_after_which_delete_log_data" {
  description = "After this number of days, Jenkins ALB access logs should be deleted from S3. Enter 0 to never delete log data."
  default     = 186
}

variable "allow_incoming_http_from_cidr_blocks" {
  description = "The CIDR blocks from which the Jenkins ALB will allow HTTP/HTTPS requests. At least one of allow_incoming_http_from_cidr_blocks or allow_incoming_http_from_security_group_ids must be non-empty, or the ALB won't be able to receive any requests!"
  type        = "list"
  default     = []
}

# ---------------------------------------------------------------------------------------------------------------------
# DEFINE CONSTANTS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "Enter the name of the Jenkins server"
  default     = "jenkins"
}

variable "jenkins_volume_encrypted" {
  description = "Set to true to encrypt the Jenins EBS volume"
  default     = false
}

variable "jenkins_device_name" {
  description = "The OS device name where the Jenkins EBS volume should be attached"
  default     = "/dev/xvdh"
}

variable "jenkins_mount_point" {
  description = "The OS path where the Jenkins EBS volume should be mounted"
  default     = "/jenkins"
}

variable "jenkins_user" {
  description = "The OS user that should be used to run Jenkins"
  default     = "jenkins"
}

variable "backup_job_metric_namespace" {
  description = "The namespace for the CloudWatch Metric the AWS lambda backup job will increment every time the job completes successfully."
  default     = "Custom/Jenkins"
}

variable "backup_job_metric_name" {
  description = "The name for the CloudWatch Metric the AWS lambda backup job will increment every time the job completes successfully."
  default     = "jenkins-backup-job"
}

variable "backup_schedule_expression" {
  description = "A cron or rate expression that specifies how often to take a snapshot of the Jenkins server for backup purposes. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html for syntax details."
  default     = "rate(1 day)"
}

variable "backup_job_alarm_period" {
  description = "How often, in seconds, the backup job is expected to run. This is the same as var.backup_schedule_expression, but unfortunately, Terraform offers no way to convert rate expressions to seconds. We add a CloudWatch alarm that triggers if the value of var.backup_job_metric_name and var.backup_job_metric_namespace isn't updated within this time period, as that indicates the backup failed to run."

  # One day in seconds
  default = 86400
}

variable "skip_health_check" {
  description = "If set to true, skip the health check, and start a rolling deployment of Jenkins without waiting for it to initially be in a healthy state. This is primarily useful if the server group is in a broken state and you want to force a deployment anyway."
  default     = false
}

variable "health_check_grace_period" {
  description = "How long, in seconds, to wait after Jenkins deploys before checking its health."
  default     = 300
}

variable "is_internal_alb" {
  description = "Set to true to make the Jenkins ALB an internal ALB that cannot be accessed from the public Internet. We strongly recommend setting this to true to keep Jenkins more secure."
  default     = true
}
