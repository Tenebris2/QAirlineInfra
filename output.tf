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

output "worker_nodes_public_ips" {
  value = [for instance in aws_instance.worker_nodes : instance.public_ip]
}

output "master_nodes_public_ips" {
  value = [for instance in aws_instance.master_nodes : instance.public_ip]
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.website_cdn.domain_name
}

output "alb_url" {
  value = aws_lb.k8s_alb.dns_name
}

output "apigw_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}
