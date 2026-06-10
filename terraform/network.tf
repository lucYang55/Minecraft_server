# Citation for the following script:
# Date: 06/10/2026
# Adapted from: I adapted the code snippets in the terraform documentation to create my script.
# Source URL: https://registry.terraform.io/providers/hashicorp/aws/latest/docs 

# Citation for the following script:
# Date: 06/10/2026
# Adapted from: I adapted the code snippets in the terraform documentation (specifically the resources page)to create my script.
# Source URL: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "minecraft_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "minecraft-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.minecraft_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "minecraft-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.minecraft_vpc.id

  tags = {
    Name = "minecraft-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.minecraft_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "minecraft-rt"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "minecraft" {
  name   = "minecraft-sg"
  vpc_id = aws_vpc.minecraft_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Minecraft"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "minecraft-sg"
  }
}
