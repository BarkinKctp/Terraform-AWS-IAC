variable "aws_region" {
  description = "AWS region for the bootstrap resources"
  type        = string
  default     = "eu-west-1"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  type        = string
  default     = "terraform-locks"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "Use 3-63 characters of lowercase letters, numbers, dots, or hyphens for the bucket name."
  }
}
