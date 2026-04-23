# Run bootstrap/ in the prod account first to create this bucket.
bucket         = "terraform-backend-bucket-aws-26-prod"
key            = "terraform-project/prod/terraform.tfstate"
region         = "eu-west-1"
dynamodb_table = "terraform-locks"
encrypt        = true
