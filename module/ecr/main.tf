data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "aip" {
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

# aip-lambda
resource "aws_ecr_repository" "aip" {
  name = "aip-lambda"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "KMS" }
  tags = {
    Name = "aip"
    Terraform = "true"
    Environment = "production"
    CreatedBy = "github:recomune/ami-aws"
  }
}

resource "aws_ecr_repository_policy" "aip" {
  repository = aws_ecr_repository.aip.name
  policy = data.aws_iam_policy_document.aip.json
}

resource "aws_ecr_lifecycle_policy" "aip" {
  repository = aws_ecr_repository.aip.name
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

# ami lambda
resource "aws_ecr_repository" "ami" {
  name = "ami-lambda"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "KMS" }
  tags = {
    Name = "aip"
    Terraform = "true"
    Environment = "production"
    CreatedBy = "github:recomune/ami"
  }
}

resource "aws_ecr_repository_policy" "ami" {
  repository = aws_ecr_repository.aip.name
  policy = data.aws_iam_policy_document.aip.json
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
