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
}

resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow inbound traffic on port 8080"
  vpc_id      = aws_instance.example_server.vpc_security_group_ids[0]

  tags = {
    Name = "GithubActionsExample"
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = aws_instance.example_server.public_ip
}