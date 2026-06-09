output "public_ip" {
  value = aws_instance.minecraft.public_ip
}

output "ami_used" {
  value = data.aws_ami.ubuntu_24_04.id
  description = "The Ubuntu 24.04 AMI that was selected"
}
