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

The workflow uses defaults from `variables.tf` for non-sensitive values (app_bucket_name, db_name, etc.) and requires only the database password as a GitHub secret.

**AWS OIDC Setup (One-Time):**
1. AWS Console: IAM → Identity Providers → Create OIDC provider
   - URL: `https://token.actions.githubusercontent.com`, Audience: `sts.amazonaws.com`
2. Create IAM role `terraform-github-actions` with Terraform permissions
3. GitHub: Repo → Settings → Environments → production
   - Add secret: `AWS_ACCOUNT_ID` = your 12-digit AWS account ID
   - Add secret: `DB_PASSWORD` = your database password

## 1) Bootstrap Backend (One-Time)

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars, verify state_bucket_name = "terraform-backend-bucket-aws-26"
terraform init
terraform apply
```

## 2) Deploy Root (Local Development)

```bash
cd ..
cp terraform.tfvars.example terraform.tfvars
```

**Edit terraform.tfvars if you want custom values:**
```hcl
# Override defaults if needed
app_bucket_name = "my-unique-prod-bucket"  # MUST be globally unique
db_name         = "proddb"
db_username     = "dbadmin"
db_password     = "your-secure-password"
ec2_instance_type = "t3.micro"
```

**Notes:**
- `app_bucket_name` MUST be globally unique (S3 buckets are global)
- If you don't create terraform.tfvars, defaults from variables.tf are used
- GitHub Actions uses defaults from variables.tf + DB_PASSWORD secret (no tfvars needed)

Then deploy:
```bash
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
