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
  name        = "allow_8080"
  description = "Allow inbound traffic on port 8080, SSH inbound, and all outbound traffic"

  // Ingress rule for port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You might want to restrict this to a specific IP range for security reasons
  }

  // Ingress rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You might want to restrict this to a specific IP range for security reasons
  }

  // Egress rule for all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Add any other necessary configuration here
}

resource "aws_instance" "example_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  user_data = <<EOF
#!/bin/bash
sudo snap install docker
sleep 30
sudo docker run -p 8080:80 -d misohu/fast-api-example:latest
EOF

  tags = {
    Name = "GithubActionsExample"
  }

  key_name = "dektop-eu-central-1"
  vpc_security_group_ids = [aws_security_group.allow_8080.id]
}

output "public_ip" {
  value = aws_instance.example_server.public_ip
}