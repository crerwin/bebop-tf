variable "environment" {
  default = "local"
}

variable "ecr_arn" {
  description = "ARN of the ECR to which to give runner role push access"
}

# This is in a module here but we probably want to ensure it only happens once
# resource "aws_iam_openid_connect_provider" "github" {
#   url             = "https://token.actions.githubusercontent.com"
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = []

#   tags = {
#     name        = "Github OpenID provider"
#     app         = "bebop"
#     environment = var.environment
#     repository  = "github.com/crerwin/bebop-tf"
#   }
# }

# assume role policy allowing Github runners for the bebop repos to assume the deploy role using Github's OIDC
data "aws_iam_policy_document" "bebop_runner_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::278421603546:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:crerwin/bebop:*"]
    }
  }
}

data "aws_iam_policy_document" "bebop_runner_policy" {
  # allow retrieval of ECR token (for docker login)
  statement {
    actions = [
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken"
    ]
    resources = ["*"]
  }

  # allow pushing to bebop repo
  statement {
    actions = [
      "ecr-public:BatchCheckLayerAvailability",
      "ecr-public:PutImage",
      "ecr-public:InitiateLayerUpload",
      "ecr-public:UploadLayerPart",
      "ecr-public:CompleteLayerUpload"
    ]

    resources = [var.ecr_arn]
  }
}

resource "aws_iam_policy" "bebop_deploy_policy" {
  name        = "bebop_deploy_policy_${var.environment}"
  path        = "/"
  description = "Deployment policy for Bebop Github Actions runners"

  policy = data.aws_iam_policy_document.bebop_runner_policy.json

  tags = {
    name        = "bebop-deploy-role-${var.environment}"
    app         = "bebop"
    environment = var.environment
    repository  = "github.com/crerwin/bebop-tf"
  }
}

resource "aws_iam_role" "bebop_deploy_role" {
  name               = "bebop-deploy-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.bebop_runner_assume_role_policy.json

  tags = {
    name        = "bebop-deploy-role-${var.environment}"
    app         = "bebop"
    environment = var.environment
    repository  = "github.com/crerwin/bebop-tf"
  }
}

resource "aws_iam_role_policy_attachment" "bebop_policy_attachment" {
  role       = aws_iam_role.bebop_deploy_role.name
  policy_arn = aws_iam_policy.bebop_deploy_policy.arn
}
