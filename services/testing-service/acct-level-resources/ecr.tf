# ---------------------------------------------------------------------------------------------------------------------
# ECR Repo 
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecr_repository" "master" {
  name = "${var.service_name}-master"
}

resource "aws_ecr_lifecycle_policy" "master_policy_greater_than_90" {
  repository = "${aws_ecr_repository.master.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images > count = 90",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 90
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "master_policy_untagged_older_than_7_days" {
  repository = "${aws_ecr_repository.master.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 2,
            "description": "Expire untagged images older than 7 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}