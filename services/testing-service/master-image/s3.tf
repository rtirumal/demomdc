#######################################
# CodeBuild/CodePipeline S3 Resources
#######################################

resource "aws_s3_bucket" "jenkins_keys" {
  bucket        = "${var.service_name}-jenkins-keys"
  acl           = "private"
  force_destroy = true
}
resource "aws_s3_bucket" "source" {
  bucket        = "${var.service_name}-build-source"
  acl           = "private"
  force_destroy = true
}
