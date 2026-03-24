# Terraform AWS IaC Project

This repository deploys a small AWS stack with Terraform using:

- a one-time backend bootstrap (`bootstrap/`) for remote state
- a root module (`main.tf`) that calls `modules/app_stack`

## What Gets Deployed

- 2 EC2 instances (web server on port 8080)
- 1 Application Load Balancer (ALB) on port 80
- 1 application S3 bucket
- 1 PostgreSQL RDS instance (private)

## Folder Layout

- `bootstrap/`:
  - creates backend resources (state S3 bucket + DynamoDB lock table)
  - run once, then reuse
- `modules/app_stack/`:
  - contains actual app infrastructure resources
- root (`main.tf`, `provider.tf`, `variables.tf`, `outputs.tf`):
  - composes module(s), configures backend, exposes outputs

## Prerequisites

- Terraform >= 1.5.7
- AWS CLI installed
- AWS credentials configured

Configure credentials:

```bash
aws configure
```

Enter:

- `AWS Access Key ID`
- `AWS Secret Access Key` (not AWS account password)
- `Default region name` (use `eu-west-1` for this project)
- `Default output format` (for example `json`)

Verify identity:

```bash
aws sts get-caller-identity
```

## 1) Bootstrap Backend (One-Time)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
```

Edit `bootstrap/terraform.tfvars` and set a globally unique value:

```hcl
state_bucket_name = "<your-unique-state-bucket-name>"
```

Then run:

```bash
terraform init
terraform apply
```

## 2) Initialize Root Backend

Bootstrap already outputs the exact command:

```bash
cd bootstrap
terraform output -raw backend_init_command
```

Copy that output and run it from project root.

What this does:

- tells root Terraform to store state in the backend S3 bucket
- uses DynamoDB for state locking

## 3) Configure Root Variables

Return to project root, then run:

```bash
cd ..
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set values:

- `app_bucket_name`
- `db_name`
- `db_username`
- `db_password`
- optional: `aws_region`, `ec2_instance_type`

Important:

- If `terraform.tfvars` exists with required values, Terraform will not prompt.
- If required values are missing, Terraform will prompt at runtime.

## 4) Deploy

Run from project root:

```bash
terraform plan
terraform apply
```

Notes:

- RDS can take several minutes to create.
- If account restrictions block a specific EC2 size, set `ec2_instance_type` in `terraform.tfvars`.

## 5) Access Outputs

```bash
terraform output app_url
terraform output alb_dns_name
```

## 6) View in AWS Console (Portal)

After deploy, open AWS Console in the same region used by Terraform and verify created resources:

- EC2: 2 running instances
- Load Balancer: 1 ALB with a DNS name
- RDS: 1 PostgreSQL DB instance (private)
- S3: 1 application bucket

Quick links:

- `https://console.aws.amazon.com/ec2/home`
- `https://console.aws.amazon.com/ec2/home#LoadBalancers:`
- `https://console.aws.amazon.com/rds/home`
- `https://s3.console.aws.amazon.com/s3/home`

## 7) Destroy App Resources

Run from project root:

```bash
terraform destroy -lock-timeout=60s
```

## 8) Optional: Destroy Backend Resources

Use this only when fully done and cleanup is required.

1. Destroy root resources first.
2. Then destroy bootstrap:

```bash
cd bootstrap
terraform destroy
```

Backend behavior:

- backend state bucket is `force_destroy = false`
- it must be empty (including versions/delete markers) before it can be destroyed

## Module Behavior

Deploy from root directly.

- Root `main.tf` calls `module "app_stack"`.
- Terraform loads module variables, resources, and outputs automatically during root `plan/apply`.

## General Notes

- Keep backend state bucket and app bucket names different and globally unique.
- Use `terraform.tfvars` to avoid runtime prompts for required variables.
- Run deploy and destroy from project root; use `bootstrap/` only for backend setup/teardown.
- Some resources (especially RDS and ALB) take longer to create or destroy.
