variable "aws_region" {
  description = "AWS region for the primary infrastructure"
  type        = string
  default     = "eu-west-1"
}

variable "app_bucket_name" {
  description = "Globally unique S3 bucket name for the application bucket"
  type        = string
  default     = "terraform-app-bucket-prod"
}

variable "db_name" {
  description = "Identifier for the RDS instance"
  type        = string
  default     = "proddb"
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8 && length(var.db_password) <= 128 && !can(regex("[/@\" ]", var.db_password))
    error_message = "Password must be 8-128 characters and must not contain /, @, \", or spaces."
  }
}

variable "ec2_instance_type" {
  description = "EC2 instance type for web instances"
  type        = string
  default     = "t3.micro"
}
