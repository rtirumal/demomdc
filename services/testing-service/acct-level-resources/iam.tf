
# ---------------------------------------------------------------------------------------------------------------------
# CODEBUILD
# ---------------------------------------------------------------------------------------------------------------------


resource "aws_iam_role" "codebuild_role_agent_build" {
  name = "codebuild-role-${var.service_name}-agent-build"

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

data "template_file" "codebuild_policy_agent_build" {
  template = "${file("${path.module}/files/codebuild_agent_build_policy.json")}"

  vars {
    aws_s3_bucket_arn                   = "${aws_s3_bucket.placeholder.arn}"
  }
}

resource "aws_iam_role_policy" "codebuild_policy_agent_build" {
  name   = "codebuild-policy-${var.service_name}-agent-build"
  role   = "${aws_iam_role.codebuild_role_agent_build.id}"
  policy = "${data.template_file.codebuild_policy_agent_build.rendered}"
}