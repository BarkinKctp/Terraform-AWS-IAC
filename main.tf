terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }

  backend "s3" {}
}

module "app_stack" {
  source = "./modules/app_stack"

  app_bucket_name = var.app_bucket_name
  db_name         = var.db_name
  db_username     = var.db_username
  db_password     = var.db_password
  ec2_instance_type = var.ec2_instance_type
}
