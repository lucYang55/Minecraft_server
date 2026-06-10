# Citation for the following script:
# Date: 06/10/2026
# Adapted from: I adapted the code snippets in the terraform documentation to create my script.
# Source URL: https://registry.terraform.io/providers/hashicorp/aws/latest/docs 

output "public_ip" {
  value = aws_instance.minecraft.public_ip
}

output "ami_used" {
  value = data.aws_ami.ubuntu_24_04.id
  description = "The Ubuntu 24.04 AMI that was selected"
}
