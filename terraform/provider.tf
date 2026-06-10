# Citation for the following script:
# Date: 06/10/2026
# Adapted from: I adapted the code snippets in the terraform documentation to create my script.
# Source URL: https://registry.terraform.io/providers/hashicorp/aws/latest/docs 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
