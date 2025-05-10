variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "RDS root user name"
  type        = string
}
