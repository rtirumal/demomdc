# ---------------------------------------------------------------------------------------------------------------------
# PACKAGE OUTPUTS
# ---------------------------------------------------------------------------------------------------------------------
output "kms_master_key_alias" {
  value = "${module.kms_master_key.key_alias}"
}

output "kms_master_key_arn" {
  value = "${module.kms_master_key.key_arn}"
}
