
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
  enabled_cloudwatch_logs_exports = ["postgresql"]
}

resource "aws_db_parameter_group" "postgres_db" {
  name   = "postgres-db-parameter-group"
  family = "postgres17"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}