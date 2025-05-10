output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.postgres_db.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres_db.port
}
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres_db.endpoint
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.postgres_db.username
}


output "worker_node_public_ips" {
  value = [for instance in aws_instance.worker_nodes : instance.public_ip]
}

output "master_nodes_public_ips" {
  value = [for instance in aws_instance.master_nodes : instance.public_ip]
}

