# Citation for the following script:
# Date: 06/10/2026
# Adapted from: I adapted the code snippets in the terraform documentation to create my script.
# Source URL: https://registry.terraform.io/providers/hashicorp/aws/latest/docs 

variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "Name of your existing EC2 key pair"
  default     = "minecraft-key"
}
