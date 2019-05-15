######################################
# ECR build agent repositories
######################################
resource "aws_ecr_repository" "ecr_agent_repo" {
  name = "${var.service_name}-${var.ecr_repo}"
}

resource "aws_ecr_lifecycle_policy" "agent_ecr_lifecycle_policy" {
  repository = "${aws_ecr_repository.ecr_agent_repo.name}"
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
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
        },
        {
            "rulePriority": 2,
            "description": "Expire images > count = 200",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 200
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
