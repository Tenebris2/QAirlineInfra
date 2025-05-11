
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
