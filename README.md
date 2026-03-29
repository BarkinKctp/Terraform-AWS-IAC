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

## GitHub Actions Workflows

**Test Workflow** (`.github/workflows/terraform-tests.yml`): Validates format, syntax, plan, linting on every push/PR. No AWS credentials needed.

**Deploy Workflow** (`.github/workflows/terraform-deploy.yml`): Deploys on push to `main` or manual trigger. Requires AWS OIDC setup.

**AWS OIDC Setup (One-Time):**
1. AWS Console: IAM → Identity Providers → Create OIDC provider
   - URL: `https://token.actions.githubusercontent.com`, Audience: `sts.amazonaws.com`
2. Create IAM role `terraform-github-actions` with Terraform permissions
3. GitHub: Repo → Settings → Environments → production → Add secret `AWS_ACCOUNT_ID`

## 1) Bootstrap Backend (One-Time)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars, verify state_bucket_name = "terraform-backend-bucket-aws-26"
terraform init
terraform apply
```

## 2) Deploy Root

```bash
cd ..
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your app configuration
terraform init
terraform plan && terraform apply
```

## 3) View Outputs & Verify

```bash
terraform output  # See all outputs
```

Check AWS Console (EC2, ALB, RDS, S3) to verify resources.

## Cleanup

```bash
# Destroy app resources
terraform destroy

# Destroy backend (when completely done)
cd bootstrap
terraform destroy  # Bucket must be empty
```
