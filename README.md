# Terraform AWS IaC Project

This project provisions a small AWS stack with Terraform and uses an S3 + DynamoDB backend for remote state.

## What It Deploys

- 2 EC2 instances running a Python HTTP server on port 8080
- 1 Application Load Balancer (ALB) on port 80
- 1 app S3 bucket (separate from the state bucket)
- 1 PostgreSQL RDS instance (private, not publicly accessible)

## Project Structure

- `bootstrap/`: one-time backend bootstrap (state bucket + lock table)
- `modules/app_stack/`: reusable module containing app infrastructure resources
- `main.tf` (root): orchestrates modules and backend settings
- `provider.tf` (root): provider configuration shared by root and modules
- `variables.tf` (root): input variables passed into modules
- `otuputs.tf` (root): outputs exposed from module outputs

## Prerequisites

- Terraform >= 1.5.7
- AWS credentials configured locally (AWS CLI profile, env vars, or SSO)

## 1) Bootstrap Backend (One-Time)

From the bootstrap folder:

```powershell
cd bootstrap
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `bootstrap/terraform.tfvars` and set:

```hcl
state_bucket_name = "<unique_s3_bucket_name_for_terraform_state>"
```

Then run:

```powershell
terraform init
terraform apply
```

Get backend init values:

```powershell
terraform output
```

## 2) Initialize Root Project Backend

From the project root, run:

```powershell
terraform init `
  -backend-config="bucket=<state_bucket_name_from_bootstrap>" `
  -backend-config="key=terraform-project/terraform.tfstate" `
  -backend-config="region=<aws_region_from_bootstrap>" `
  -backend-config="dynamodb_table=<dynamodb_table_name_from_bootstrap>" `
  -backend-config="encrypt=true"
```

## 3) Configure App Variables

From the project root:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set values for:

- `app_bucket_name`
- `db_name`
- `db_username`
- `db_password`
- optionally `aws_region`

## 4) Deploy

```powershell
terraform plan
terraform apply
```

## 5) Access the App

After apply:

```powershell
terraform output app_url
```

Open the output URL in a browser.

## Notes

- Keep backend state bucket and app bucket names different and globally unique.
- The current demo app serves a static `Hello, World!` page.
