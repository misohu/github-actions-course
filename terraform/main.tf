terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-central-1"
}

resource "aws_instance" "example_server" {
  ami           = "ami-0faab6bdbac9486fb "
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
    Name = "JacksBlogExample"
  }
}

resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow inbound traffic on port 8080"
  vpc_id      = example_server.ec2_instance.vpc_security_group_ids[0]

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value = example_server.ec2_instance.public_ip
}