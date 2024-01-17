terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "allow_8080" {
  name        = "example"
  description = "Allow inbound traffic on port 8080"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You might want to restrict this to a specific IP range for security reasons
  }

  // Add any other necessary configuration here
}

resource "aws_instance" "example_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  user_data = <<EOF
#!/bin/bash
sudo snap install docker
sudo addgroup --system docker
sudo adduser ubuntu docker
newgrp docker
sudo snap disable docker
sudo snap enable docker
EOF

  tags = {
    Name = "GithubActionsExample"
  }

  key_name = "dektop-eu-central-1"
  security_groups = [aws_security_group.example.id]
}

output "public_ip" {
  value = aws_instance.example_server.public_ip
}