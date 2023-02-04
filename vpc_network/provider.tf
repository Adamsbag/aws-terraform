terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "wordpress-aws-2023"
    key            = "backend.tfstate"
    region         = "us-east-1"
    dynamodb_table = "wordpress-remote-db"
  }

}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
