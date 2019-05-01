#######################################
# CodeBuild/CodePipeline S3 Resources
#######################################

resource "aws_s3_bucket" "source" {
  bucket        = "${var.service_name}-${var.env_name}-deploy-source"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "deploy" {
  bucket        = "${var.service_name}-${var.env_name}-deploy"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.deploy.id}"
  key    = "placeholder.zip"
  source = "files/placeholder.zip"
}
