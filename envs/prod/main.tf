terraform {
  required_version = "1.3.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.51.0"
    }
  }

  backend "s3" {
    bucket = "bebop-tfstate-prod"
    key    = "bebop/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "state-bucket" {
  source      = "../../modules/state-bucket"
  environment = "prod"
}

module "ecr" {
  source      = "../../modules/ecr"
  environment = "prod"
}

module "iam" {
  source      = "../../modules/iam"
  environment = "prod"
  ecr_arn     = module.ecr.ecr_arn
}
