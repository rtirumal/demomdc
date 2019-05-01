# ---------------------------------------------------------------------------------------------------------------------
# CODEBUILD 
# ---------------------------------------------------------------------------------------------------------------------
output "codebuild_master_build_project_id" {
  value = "${aws_codebuild_project.master_build.id}"
}

output "codebuild_master_build_project_arn" {
  value = "${aws_codebuild_project.master_build.arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CODEPIPELINE
# ---------------------------------------------------------------------------------------------------------------------

output "codepipeline_master_build_project_id" {
  value = "${aws_codepipeline.pipeline.id}"
}
output "codepipeline_master_build_project_arn" {
  value = "${aws_codepipeline.pipeline.arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------------------------------------------------------

output "iam_codepipeline_role_arn" {
  value = "${aws_iam_role.codepipeline_role.arn}"
}

output "iam_codepipeline_role_id" {
  value = "${aws_iam_role.codepipeline_role.id}"
}

output "iam_codepipeline_role_name" {
  value = "${aws_iam_role.codepipeline_role.name}"
}

output "iam_codebuild_role_arn" {
  value = "${aws_iam_role.codebuild_role.arn}"
}

output "iam_codebuild_role_id" {
  value = "${aws_iam_role.codebuild_role.id}"
}

output "iam_codebuild_role_name" {
  value = "${aws_iam_role.codebuild_role.name}"
}



# ---------------------------------------------------------------------------------------------------------------------
# S3 
# ---------------------------------------------------------------------------------------------------------------------

output "jenkins_keys_bucket_id" {
  value = "${aws_s3_bucket.jenkins_keys.id}"
}

output "jenkins_keys_bucket_arn" {
  value = "${aws_s3_bucket.jenkins_keys.arn}"
}