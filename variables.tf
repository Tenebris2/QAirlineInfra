variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "RDS root user name"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "qairlines-website-react-bucket"
}

variable "created_by" {
  description = "Name of the person who created the resources"
  type        = string
  default     = "Terraform"
}

variable "object_ownership" {
  description = "S3 bucket ownership controls"
  type        = string
  default     = "BucketOwnerPreferred"
}

variable "alert_email" {
  description = "Email nhận cảnh báo CloudWatch"
  type        = string
}