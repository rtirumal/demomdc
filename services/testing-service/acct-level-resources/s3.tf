# ---------------------------------------------------------------------------------------------------------------------
# JENKINS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "placeholder" {
  bucket        = "${var.service_name}-placeholder"
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.placeholder.id}"
  key    = "placeholder.zip"
  source = "files/placeholder.zip"
}