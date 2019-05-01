# --------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator when calling this
# terraform module.
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
#  Global Variables expected from *.tfvars files in inventory
# --------------------------------------------------------------------------------
variable "aws_account_id" {
  description = "AWS Account ID where resources should be created"
}

variable "aws_region" {
  description = "aws region to deploy resources"
}

variable "terraform_state_aws_region" {
  description = "region where terraform state files are stored in S3. Used for data lookups of remote tfstate."
}

variable "terraform_state_s3_bucket" {
  description = "S3 bucket name where terraform state file exist. Used for data lookups of remote terraform state"
}

variable "service_name" {
  description = "The Name of the service (without environment designation). Also used to create the Name tag of all service resources in this module."
  default     = ""
}

variable "component_name" {
  description = "The Name of the service sub-module (without environment designation). Also used to create the Name tag of all service resources in this module."
  default     = ""
}

variable "service_environment" {
  description = "Valid values for this variable are 'stage' or 'prod'. Also used to construct Name of any service resources in this package."
  default     = "stage"
}

variable "vpc_name" {
  description = "VPC name. Used in state file lookup. Usually inherited from env.tfvars file."
}

variable "name" {
  description = "The name used to namespace all resources created by these templates, including the cluster and cluster instances (e.g. drupaldb). Must be unique in this region. Must be a lowercase string."
}

variable "db_name" {
  description = "The name for your database of up to 8 alpha-numeric characters. If you do not provide a name, Amazon RDS will not create a database in the DB cluster you are creating."
  default     = ""
}

variable "master_username" {
  description = "The username for the master user."
}

variable "instance_count" {
  description = "How many instances to launch. RDS will automatically pick a leader and configure the others as replicas."
}

# See https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Aurora.Managing.html for the instance types supported by
# Aurora
variable "instance_type" {
  description = "The instance type to use for the db (e.g. db.r3.large)"
}

# --------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# --------------------------------------------------------------------------------
variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0.  Allowed values: 0, 1, 5, 15, 30, 60"
  default     = 0
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Be sure this role exists. It will not be created here. You must specify a MonitoringInterval value other than 0 when you specify a MonitoringRoleARN value that is not empty string."
  default     = ""
}

# --------------------------------------------------------------------------------
# DEFINE CONSTANTS
# Generally, these values won't need to be changed.
# --------------------------------------------------------------------------------

# Use the default MySQL port
variable "port" {
  description = "The port the DB will listen on (e.g. 3306)"
  default     = 3306
}

variable "backup_retention_period" {
  description = "How many days to keep backup snapshots around before cleaning them up"
  default     = 21
}

# By default, run backups from 2-3am EST, which is 6-7am UTC
variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created (e.g. 04:00-09:00). Time zone is UTC. Performance may be degraded while a backup runs."
  default     = "06:00-07:00"
}

# By default, do maintenance from 3-4am EST on Sunday, which is 7-8am UTC. For info on whether DB changes cause
# degraded performance or downtime, see:
# http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html
variable "preferred_maintenance_window" {
  description = "The weekly day and time range during which system maintenance can occur (e.g. wed:04:00-wed:04:30). Time zone is UTC. Performance may be degraded or there may even be a downtime during maintenance windows."
  default     = "sun:07:00-sun:08:00"
}

# By default, only apply changes during the scheduled maintenance window, as certain DB changes cause degraded
# performance or downtime. For more info, see:
# http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html
variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Note that cluster modifications may cause degraded performance or downtime."
  default     = false
}

# Note: you cannot enable encryption on an existing DB, so you have to enable it for the very first deployment. If you
# already created the DB unencrypted, you'll have to create a new one with encryption enabled and migrate your data to
# it. For more info on RDS encryption, see: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html
variable "storage_encrypted" {
  description = "Specifies whether the DB cluster uses encryption for data at rest in the underlying storage for the DB, its automated backups, Read Replicas, and snapshots. Uses the default aws/rds key in KMS."
  default     = false
}

variable "allow_connections_from_cidr_blocks" {
  description = "Specifies a list of CIDR blocks to allow connections from."
  type        = "list"
  default     = []
}

variable "allow_connections_from_security_groups" {
  description = "Specifies a list of Security Groups to allow connections from."
  type        = "list"
  default     = []
}

variable "kms_key_arn" {
  description = "The ARN of a KMS key that should be used to encrypt data on disk. Only used if var.storage_encrypted is true. If you leave this blank, the default RDS KMS key for the account will be used."
  default     = ""
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. Disabled by default."
  default     = false
}

variable "custom_tags" {
  description = "A map of custom tags to apply to the Aurora RDS Instance and the Security Group created for it. The key is the tag name and the value is the tag value."
  type        = "map"
  default     = {}
}

variable "snapshot_identifier" {
  description = "If non-empty, the Aurora cluster will be restored from the given Snapshot ID. This is the Snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  default     = ""
}

variable "engine" {
  description = "The name of the database engine to be used for the RDS instance. Must be one of: aurora, aurora-postgresql."
  default     = "aurora"
}

variable "engine_version" {
  description = "The version of the engine in var.engine to use."
  default     = ""
}

variable "db_cluster_parameter_group_name" {
  description = "A cluster parameter group to associate with the cluster. Parameters in a DB cluster parameter group apply to every DB instance in a DB cluster."
  default     = ""
}

variable "db_instance_parameter_group_name" {
  description = "An instance parameter group to associate with the cluster instances. Parameters in a DB parameter group apply to a single DB instance in an Aurora DB cluster."
  default     = ""
}
