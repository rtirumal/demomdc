# --------
#  Global Variables expected from *.tfvars files in inventory
# --------

variable "aws_region" {
  description = "aws region to deploy resources"
}

variable "aws_account_id" {
  description = "AWS Account ID where resources should be created"
}

variable "terraform_state_aws_region" {
  description = "region where terraform state files are stored in S3. Used for data lookups of remote tfstate."
}

variable "terraform_state_s3_bucket" {
  description = "S3 bucket name where terraform state file exist. Used for data lookups of remote terraform state"
}

variable "vpc_name" {
  description = "VPC name. Used in state file lookup. Usually inherited from env.tfvars file."
}

# --------
# Common User Variables
# --------

variable "name" {
  description = "Unique name used in all resource names to identify related package resources"
}

variable "cluster_version" {
  description = "Version of Redshift engine cluster"
  default     = "1.0"

  # Only version 1.0 is currently available.
  # http://docs.aws.amazon.com/cli/latest/reference/redshift/create-cluster.html
}

variable "cluster_node_type" {
  description = "Node Type of Redshift cluster"

  # Valid Values include: dc2.large | dc2.8xlarge | ds2.xlarge | ds2.8xlarge
  # http://docs.aws.amazon.com/cli/latest/reference/redshift/create-cluster.html
}

variable "cluster_number_of_nodes" {
  description = "Number of nodes in the cluster (values greater than 1 will trigger 'cluster_type' of 'multi-node')"
  default     = 3
}

variable "cluster_database_name" {
  description = "The name of the database to create"
}

# Self-explainatory variables
variable "cluster_master_username" {
  description = "The database master username"
}

variable "cluster_master_password" {
  description = "The database master username's password"
}

variable "cluster_port" {
  default = 5439
}

variable "cluster_iam_roles" {
  description = "A list of IAM Role ARNs associated with the cluster. (Max of 10 per cluster)"
  type        = "list"
  default     = []
}

variable "final_snapshot_identifier" {
  description = "(Required if skip_final_snapshot is false) The identifier of the final snapshot created immediately before deleting the cluster."
  default     = "default-final-snapshot-identifier"
}

variable "skip_final_snapshot" {
  description = "If true (default), no snapshot created before deleting DB"
  default     = true
}

variable "preferred_maintenance_window" {
  description = "When AWS can run snapshot, cannot overlap with maintenance window"
  default     = "sat:10:00-sat:10:30"
}

variable "automated_snapshot_retention_period" {
  description = "How long in days to keep snapshots"
  default     = 10
}

variable "wlm_json_configuration" {
  default = "[{\"query_concurrency\": 5}]"
}

variable "tags" {
  description = "Mapping of tags applied to all resources."
  default     = {}
}

variable "encrypted" {
  description = "(Optional) To encrypt cluster data at rest. (use with kms_key_id.)"
  default     = true
}

variable "kms_key_id" {
  description = "(Optional) to specify KMS encryption key arn. (encrypted value must be true.)"
  default     = ""
}

variable "allow_version_upgrade" {
  description = "(Optional) to allow Redshift major version cluster upgrade during maintenance window."
  default     = true
}

variable "s3_log_bucket_name" {
  description = "S3 bucket name (bucket id) for redshift logs. The bucket and bucket policy will be created."
}

variable "log_retention_in_days" {
  description = "Number of days to keep redshift logs"
  default     = 365
}

variable "logging_s3_key_prefix" {
  description = "prefix of redshift logs in s3 bucket"
  default     = "log/"
}
