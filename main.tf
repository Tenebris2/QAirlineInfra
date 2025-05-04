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
  region  = "ap-southeast-1"
  profile = "devops-user"
}

locals {
  instance_count = 3
  instance_type  = "t2.micro"
}

resource "aws_vpc" "demo_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "subnet" {
  cidr_block        = cidrsubnet(aws_vpc.demo_vpc.cidr_block, 8, 0)
  vpc_id            = aws_vpc.demo_vpc.id
  availability_zone = var.availabiliy_zone
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.demo_vpc.id
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.demo_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_security_group" "security-allow-web" {
  name = "allow-http-https"

  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security-allow-ssh" {
  name = "allow-my-ssh"

  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security-allow-db-access" {
  name = "allow-db-access"

  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "my-ec2-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_instance" "frontend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.security-allow-ssh.id}", "${aws_security_group.security-allow-web.id}"]
  tags = {
    Name = "frontend"
  }
  subnet_id = aws_subnet.subnet.id
}

resource "aws_instance" "backend" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.security-allow-ssh.id}", "${aws_security_group.security-allow-web.id}"]
  tags = {
    Name = "backend"
  }
  subnet_id = aws_subnet.subnet.id
}

resource "aws_instance" "db" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.security-allow-ssh.id}", "${aws_security_group.security-allow-db-access.id}"]
  tags = {
    Name = "postgres-db"
  }
  subnet_id = aws_subnet.subnet.id
}


output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_public_ip" {
  value = aws_instance.backend.public_ip
}

output "db_public_ip" {
  value = aws_instance.db.public_ip
}
