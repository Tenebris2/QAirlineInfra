
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
  security_groups             = [
    aws_security_group.security-allow-ssh.id,
    aws_security_group.security-allow-web.id,
    aws_security_group.security-allow-cluster-control-plane.id
  ]
  subnet_id = aws_subnet.subnet_1.id

  tags = {
    Name = "master_nodes"
  }
}

resource "aws_instance" "worker_nodes" {
  count                       = local.worker_nodes_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  associate_public_ip_address = true
  security_groups             = [
    aws_security_group.security-allow-ssh.id,
    aws_security_group.security-allow-web.id,
    aws_security_group.security-allow-cluster-worker.id
  ]
  subnet_id = aws_subnet.subnet_1.id

  tags = {
    Name = "worker_nodes"
  }
}
