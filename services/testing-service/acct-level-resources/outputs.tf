# ---------------------------------------------------------------------------------------------------------------------
# ECR Repo 
# ---------------------------------------------------------------------------------------------------------------------

output "ecr_repo_master_url" {
  value = "${aws_ecr_repository.master.repository_url}"
}

output "ecr_repo_master_arn" {
  value = "${aws_ecr_repository.master.arn}"
}

output "ecr_repo_master_name" {
  value = "${aws_ecr_repository.master.name}"
}


# ---------------------------------------------------------------------------------------------------------------------
# S3 
# ---------------------------------------------------------------------------------------------------------------------

output "placeholder_bucket_id" {
  value = "${aws_s3_bucket.placeholder.id}"
}

output "placeholder_bucket_arn" {
  value = "${aws_s3_bucket.placeholder.arn}"
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM 
# ---------------------------------------------------------------------------------------------------------------------

output "codebuild_role_agent_build_arn" {
  value = "${aws_iam_role.codebuild_role_agent_build.arn}"
}

output "codebuild_role_agent_build_id" {
  value = "${aws_iam_role.codebuild_role_agent_build.id}"
}


output "codebuild_role_agent_build_name" {
  value = "${aws_iam_role.codebuild_role_agent_build.name}"
}

output "codebuild_policy_agent_build_id" {
  value = "${aws_iam_role_policy.codebuild_policy_agent_build.id}"
}

output "codebuild_policy_agent_build_name" {
  value = "${aws_iam_role_policy.codebuild_policy_agent_build.name}"
}