output "instance_1_public_ip" {
  description = "Public IP of EC2 instance 1"
  value       = aws_instance.instance_1.public_ip
}

output "instance_2_public_ip" {
  description = "Public IP of EC2 instance 2"
  value       = aws_instance.instance_2.public_ip
}

output "app_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = aws_s3_bucket.example.id
}

output "app_bucket_arn" {
  description = "ARN of the application S3 bucket"
  value       = aws_s3_bucket.example.arn
}

output "db_endpoint" {
  description = "Connection endpoint for the RDS instance (host:port)"
  value       = aws_db_instance.db_instance.endpoint
}

output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = aws_lb.application_load_balancer.dns_name
}
