# --- EC2 ---
output "instance_1_public_ip" {
  description = "Public IP of EC2 instance 1"
  value       = module.app_stack.instance_1_public_ip
}

output "instance_2_public_ip" {
  description = "Public IP of EC2 instance 2"
  value       = module.app_stack.instance_2_public_ip
}

# --- S3 ---
output "app_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = module.app_stack.app_bucket_name
}

output "app_bucket_arn" {
  description = "ARN of the application S3 bucket"
  value       = module.app_stack.app_bucket_arn
}

# --- RDS ---
output "db_endpoint" {
  description = "Connection endpoint for the RDS instance (host:port)"
  value       = module.app_stack.db_endpoint
}

# --- Load Balancer ---

output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = module.app_stack.alb_dns_name
}

output "app_url" {
  description = "Open this URL in a browser to access the app without a custom domain"
  value       = "http://${module.app_stack.alb_dns_name}"
}
