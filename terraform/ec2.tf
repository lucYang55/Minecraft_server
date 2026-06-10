# Citation for the following script:
# Date: 06/10/2026
# Adapted from: I adapted the code snippets in the terraform documentation to create my script.
# Source URL: https://registry.terraform.io/providers/hashicorp/aws/latest/docs 

# Citation for the following script:
# Date: 06/10/2026
# Adapted from: Amazon EC2 AMI Locator to find the correct filter name pattern for Ubuntu 24.04 and verify the owner ID 
# Source URL: http://cloud-images.ubuntu.com/locator/ec2/

# Citation for the following script:
# Date: 06/10/2026
# Adapted from: terraform documentation to find the correct filter name pattern for Ubuntu 24.04 and verify the owner ID 
# Source URL: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#root_block_device

# Automatically find the latest Ubuntu 24.04 LTS AMI for the current region
data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "minecraft" {
  ami           = data.aws_ami.ubuntu_24_04.id
  instance_type = "t2.small"

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.minecraft.id]

  key_name = var.key_name

  # Ensure the instance has enough root volume space
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "MinecraftServer"
  }
}
