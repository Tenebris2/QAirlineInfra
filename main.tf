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
  worker_nodes_count = 2
  master_nodes_count = 1
  instance_type      = "t2.micro"
  db_instance_type   = "db.t3.micro"
  db_engine          = "postgres"
  db_engine_version  = "17.2"
  availabiliy_zone_1 = "ap-southeast-1a"
  availabiliy_zone_2 = "ap-southeast-1b"
  cidr_block         = "10.0.0.0/16"
  multi_az           = false
  allocated_storage  = 5
  http_port          = 80
  https_port         = 443
  ssh_port           = 22
  postgres_port      = 5432
}

resource "aws_vpc" "demo_vpc" {
  cidr_block           = local.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "subnet_1" {
  cidr_block        = cidrsubnet(aws_vpc.demo_vpc.cidr_block, 8, 0)
  vpc_id            = aws_vpc.demo_vpc.id
  availability_zone = local.availabiliy_zone_1
}

resource "aws_subnet" "subnet_2" {
  cidr_block        = cidrsubnet(aws_vpc.demo_vpc.cidr_block, 8, 1)
  vpc_id            = aws_vpc.demo_vpc.id
  availability_zone = local.availabiliy_zone_2
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

    from_port = local.http_port
    to_port   = local.http_port
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

    from_port = local.https_port
    to_port   = local.https_port
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

    from_port = local.ssh_port
    to_port   = local.ssh_port
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "security-allow-cluster-worker" {
  name   = "worker-node-security-group"
  vpc_id = aws_vpc.demo_vpc.id

  # Kubelet API
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubelet API"
  }

  # kube-proxy
  ingress {
    from_port   = 10256
    to_port     = 10256
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "kube-proxy"
  }

  # NodePort Services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort Services"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "security-allow-cluster-control-plane" {
  name   = "allow-k8s-control-plane"
  vpc_id = aws_vpc.demo_vpc.id

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubernetes API server"
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "etcd server client API"
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubelet API"
  }

  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "kube-scheduler"
  }

  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "kube-controller-manager"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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

    from_port = local.postgres_port
    to_port   = local.postgres_port
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "postgres_db" {
  identifier             = "postgres-db"
  instance_class         = local.db_instance_type
  allocated_storage      = local.allocated_storage
  engine                 = local.db_engine
  engine_version         = local.db_engine_version
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.security-allow-db-access.id]
  parameter_group_name   = aws_db_parameter_group.postgres_db.name
  multi_az               = local.multi_az
  publicly_accessible    = true
  skip_final_snapshot    = true
}

resource "aws_db_parameter_group" "postgres_db" {
  name   = "postgres-db-parameter-group"
  family = "postgres17"

  parameter {
    name  = "log_connections"
    value = "1"
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
resource "aws_instance" "master_nodes" {
  count                       = local.master_nodes_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.security-allow-ssh.id}", "${aws_security_group.security-allow-web.id}", "${aws_security_group.security-allow-cluster-control-plane.id}"]
  tags = {
    Name = "worker_nodes"
  }
  subnet_id = aws_subnet.subnet_1.id
}

resource "aws_instance" "worker_nodes" {
  count                       = local.worker_nodes_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.security-allow-ssh.id}", "${aws_security_group.security-allow-web.id}", "${aws_security_group.security-allow-cluster-worker.id}"]
  tags = {
    Name = "worker_nodes"
  }
  subnet_id = aws_subnet.subnet_1.id
}



