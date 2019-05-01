# ---------------------------------------------------------------------------------------------------------------------
# JENKINS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ssm_parameter" "testing_service_ldap_username" {
 name      = "/${var.service_name}/${var.env_name}/api/ldap-username"
 type      = "String"
 value     = "${var.testing_service_ldap_username}"
 overwrite = true

 tags {
   VPC = "${var.vpc_name}"
 }
}

resource "aws_ssm_parameter" "testing_service_ldap_password" {
 name      = "/${var.service_name}/${var.env_name}/api/ldap-password"
 type      = "SecureString"
 value     = "placeholder"
 overwrite = false

 lifecycle {
   ignore_changes  = ["overwrite","value"]
 }

 tags {
   VPC = "${var.vpc_name}"
 }
}

resource "aws_ssm_parameter" "testing_service_jenkins_job_url" {
 name      = "/${var.service_name}/${var.env_name}/api/jenkins-job-url"
 type      = "String"
 value     = "${var.testing_service_jenkins_job_url}"
 overwrite = true

 tags {
   VPC = "${var.vpc_name}"
 }
}

resource "aws_ssm_parameter" "testing_service_jenkins_job_token" {
 name      = "/${var.service_name}/${var.env_name}/api/jenkins-job-token"
 type      = "SecureString"
 value     = "placeholder"
 overwrite = false

 lifecycle {
   ignore_changes  = ["overwrite","value"]
 }

 tags {
   VPC = "${var.vpc_name}"
 }
}

resource "aws_ssm_parameter" "testing_service_jenkins_aws_access_key" {
 name      = "/${var.service_name}/${var.env_name}/jenkins/aws-access-key"
 type      = "SecureString"
 value     = "placeholder"
 overwrite = false

 lifecycle {
   ignore_changes  = ["overwrite","value"]
 }
}

resource "aws_ssm_parameter" "testing_service_jenkins_aws_secret_key" {
 name      = "/${var.service_name}/${var.env_name}/jenkins/aws-secret-key"
 type      = "SecureString"
 value     = "placeholder"
 overwrite = false

 lifecycle {
   ignore_changes  = ["overwrite","value"]
 }
}

# ---------------------------------------------------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ssm_parameter" "jenkins_artifacts" {
 name      = "/${var.service_name}/${var.env_name}/jenkins/artifacts-bucket"
 type      = "String"
 value     = "${aws_s3_bucket.jenkins_artifacts.id}"
}

resource "aws_ssm_parameter" "jenkins_build_packages" {
 name      = "/${var.service_name}/${var.env_name}/jenkins/build-packages-bucket"
 type      = "String"
 value     = "${aws_s3_bucket.jenkins_build_packages.id}"
}