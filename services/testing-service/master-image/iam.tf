##################################
# Codepipeline Role
##################################

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role-${var.service_name}-${var.env_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
    EOF
}

data "template_file" "codepipeline_policy" {
  template = "${file("${path.module}/files/codepipeline.json")}"

  vars {
    aws_s3_bucket_arn                   = "${aws_s3_bucket.source.arn}"
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline-policy-${var.service_name}-${var.env_name}"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = "${data.template_file.codepipeline_policy.rendered}"
}

##################################
# Codebuild Role
##################################
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-${var.service_name}-${var.env_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
 EOF
}

data "template_file" "codebuild_policy" {
  template = "${file("${path.module}/files/codebuild_policy.json")}"

  vars {
    aws_s3_bucket_source_arn                   = "${aws_s3_bucket.source.arn}"
    aws_s3_bucket_jenkins_keys_arn = "${var.jenkins_keys_bucket_arn}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild-policy-${var.service_name}-${var.env_name}"
  role   = "${aws_iam_role.codebuild_role.id}"
  policy = "${data.template_file.codebuild_policy.rendered}"
}
