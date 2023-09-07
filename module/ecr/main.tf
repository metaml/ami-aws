resource "aws_ecr_repository" "babel" {
  name = "babel"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "KMS" }
  tags = {
    Name = "babel"
    Terraform = "true"
    Environment = "production"
    CreatedBy = "github:karmanplus/babel-aws"
  }

}

resource "aws_ecr_repository_policy" "babel" {
  repository = aws_ecr_repository.babel.name
  policy = data.aws_iam_policy_document.babel.json
}

resource "aws_ecr_lifecycle_policy" "babel" {
  repository = aws_ecr_repository.babel.name
  policy = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "keep last 3 images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["v"],
          "countType": "imageCountMoreThan",
          "countNumber": 3
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "babel" {
  statement {
    sid = "EcrRegistryPowerUser"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}
