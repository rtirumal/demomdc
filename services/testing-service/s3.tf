# ---------------------------------------------------------------------------------------------------------------------
# CODEBUILD/CODEPIPELINE
# ---------------------------------------------------------------------------------------------------------------------


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

# ---------------------------------------------------------------------------------------------------------------------
# JENKINS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "jenkins_artifacts" {
  bucket        = "${var.service_name}-${var.env_name}-jenkins-artifacts"
  acl           = "private"
  force_destroy = false
}
resource "aws_s3_bucket" "jenkins_build_packages" {
  bucket        = "${var.service_name}-${var.env_name}-jenkins-build-packages"
  acl           = "private"
  force_destroy = false

  lifecycle_rule {
    id      = "build_packages_glacier"
    enabled = true

    transition {
      days          = 7
      storage_class = "GLACIER"
    }
  }

 lifecycle_rule {
    id      = "build_packages_remove"
    enabled = true

    expiration {
      days = 90
    }
  }
}
