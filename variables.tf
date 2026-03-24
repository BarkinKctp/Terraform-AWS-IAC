variable "aws_region" {
  description = "AWS region for the primary infrastructure"
  type        = string
  default     = "eu-west-1"
}

variable "app_bucket_name" {
  description = "Globally unique S3 bucket name for the application bucket"
  type        = string
}

variable "db_name" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
}
