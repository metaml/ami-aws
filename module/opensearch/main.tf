resource "aws_opensearchserverless_security_policy" "babel-encryption" {
  name        = "babel-encryption"
  type        = "encryption"
  description = "encryption policy for collections"
  policy = jsonencode({
    Rules = [
      {
        Resource = [ "collection/*" ],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_collection" "babel-github" {
  name = "github"
  type = "SEARCH"
  depends_on = [aws_opensearchserverless_security_policy.babel-encryption]
}

resource "aws_opensearchserverless_collection" "babel-slack" {
  name = "slack"
  type = "SEARCH"  
  depends_on = [aws_opensearchserverless_security_policy.babel-encryption]
}

resource "aws_opensearchserverless_security_policy" "babel-security" {
  name        = "babel-security"
  type        = "network"
  description = "public access for dashboard, VPC access for collection endpoint"
  policy = jsonencode([
    {
      Description = "VPC access for collection endpoint",
      Rules = [
        {
          Resource = [ "collection/*" ],
          ResourceType = "collection"
        }
      ],
      AllowFromPublic = false,
      SourceVPCEs = [ "vpce-035cc2b67dd2bde1b" ]
    },
    {
      Description = "Public access for dashboards",
      Rules = [
        {
          ResourceType = "dashboard",
          Resource = [ "collection/*" ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

data "aws_caller_identity" "current" {}

resource "aws_opensearchserverless_access_policy" "babel-collection" {
  name        = "babel-collection"
  type        = "data"
  description = "allow index and collection access"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [ "index/github/*", "index/slack/*" ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [ "collection/github", "collection/slack" ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        data.aws_caller_identity.current.arn
      ]
    }
  ])
}

