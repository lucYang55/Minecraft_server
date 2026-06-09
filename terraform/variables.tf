variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "Name of your existing EC2 key pair"
  default     = "minecraft-key"
}
