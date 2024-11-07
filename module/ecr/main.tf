data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "ami" {
  statement {
    sid = "EcrRegistryPowerUser"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImageScanFindings",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:ListTagsForResource",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# ami-lambda
resource "aws_ecr_repository" "ami" {
  name = "ami-lambda"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "KMS" }
  tags = {
    Name = "ami"
    Terraform = "true"
    Environment = "production"
    CreatedBy = "github:recomune/ami-aws"
  }
}

resource "aws_ecr_repository_policy" "ami" {
  repository = aws_ecr_repository.ami.name
  policy = data.aws_iam_policy_document.ami.json
}

resource "aws_ecr_lifecycle_policy" "ami" {
  repository = aws_ecr_repository.ami.name
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
