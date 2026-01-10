# Deployment Guide

## Enterprise-Grade Multi-Account ECS Fargate CI/CD Platform

This guide walks you through deploying the complete ECS Fargate platform from scratch.

---

## Prerequisites

### Required Tools

- AWS CLI v2 configured with appropriate credentials
- Terraform >= 1.0
- Docker (for local testing)
- Git

### Required AWS Setup

- ✅ AWS Organization with accounts created
- ✅ Day-0 VPC StackSet deployed (CloudFormation-StackSet-Day-0-VPC-IAM-Bootstrap-Foundation)
- ✅ VPC, Subnets, VPC Endpoints, and CI/CD Deploy Roles exist in each account

---

## Account Configuration

| Account   | ID           | Purpose                    |
|-----------|--------------|----------------------------|
| Tooling   | 472294262990 | CI/CD, ECR, State Storage  |
| Dev       | 067847734974 | Development workloads      |
| Staging   | 956574163435 | Pre-production testing     |
| Prod      | 235249476696 | Production workloads       |

---

## Deployment Steps

### Step 1: Bootstrap OIDC in Tooling Account

This step creates the GitHub OIDC provider and IAM role. It uses **local state** initially.

```bash
cd infrastructure/tooling/bootstrap

# Initialize with local state
terraform init

# Apply to create OIDC and IAM role
terraform apply
```

**Important Outputs:**
- `github_oidc_provider_arn`: OIDC Provider ARN
- `github_actions_role_arn`: Role ARN for GitHub Actions

### Step 2: Deploy Tooling Infrastructure

After bootstrap, deploy S3, DynamoDB, KMS, and ECR.

```bash
cd infrastructure/tooling

# Comment out backend.tf initially OR create bucket/table manually first
# Then initialize with local state
terraform init

# Apply to create infrastructure
terraform apply
```

**Created Resources:**
- S3 bucket: `ecs-fargate-cicd-tfstate-472294262990`
- DynamoDB table: `ecs-fargate-cicd-tfstate-lock`
- KMS key: `ecs-fargate-cicd-key`
- ECR repository: `ecs-fargate-cicd-inventory-api`

### Step 3: Migrate Bootstrap to Remote State

After S3 and DynamoDB exist, migrate the bootstrap state:

```bash
cd infrastructure/tooling/bootstrap

# Update backend to use S3 (modify main.tf)
# Change from:
#   backend "local" { ... }
# To:
#   backend "s3" {
#     bucket         = "ecs-fargate-cicd-tfstate-472294262990"
#     key            = "tooling/bootstrap/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "ecs-fargate-cicd-tfstate-lock"
#   }

terraform init -migrate-state
```

### Step 4: Configure Environment Variables

Get outputs from Day-0 StackSet for each environment:

```bash
# From Dev account CloudFormation Stack outputs
aws cloudformation describe-stacks \
  --stack-name day0-dev-foundation \
  --query "Stacks[0].Outputs" \
  --profile dev-account
```

Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in:
- VPC ID
- Public Subnet IDs
- Private Subnet IDs
- ALB Security Group ID

### Step 5: Deploy Dev Environment

```bash
cd infrastructure/environments/dev

# Create terraform.tfvars with actual values
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with real values

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

### Step 6: Configure GitHub Repository

1. **Create GitHub Environments:**
   - Go to Settings → Environments
   - Create: `dev`, `staging`, `production`
   - For `staging` and `production`: Enable "Required reviewers"

2. **Push Code to GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Initial ECS Fargate CI/CD platform"
   git remote add origin https://github.com/evansosei0707/Enterprise-Grade-Multi-Account-CI-CD-Platform-on-AWS-with-ECS.git
   git push -u origin main
   ```

3. **Verify Workflow Runs:**
   - Push to main triggers `build-and-deploy-dev.yml`
   - Monitor Actions tab for deployment status

---

## Continuous Deployment Flow

### Auto-Deploy to Dev
```
Push to main → Build Image → Push to ECR → Deploy to Dev
```

### Promote to Staging
1. Go to Actions → Deploy to Staging
2. Enter image tag (Git SHA from Dev deployment)
3. Approve deployment in GitHub Environment

### Promote to Prod
1. Go to Actions → Deploy to Production
2. Enter image tag
3. Type "DEPLOY" to confirm
4. Approve deployment in GitHub Environment

---

## Verification

### Test the Application

```bash
# Get ALB DNS from Terraform output
cd infrastructure/environments/dev
ALB_DNS=$(terraform output -raw alb_dns_name)

# Health check
curl http://$ALB_DNS/health

# Create an item
curl -X POST http://$ALB_DNS/items \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Item", "quantity": 10}'

# List items
curl http://$ALB_DNS/items
```

### Check CloudWatch Logs

```bash
aws logs tail /ecs/ecs-fargate-cicd-dev --follow
```

---

## Troubleshooting

### OIDC Authentication Fails
- Verify OIDC provider thumbprint
- Check GitHub repo name in trust policy matches exactly
- Ensure branch name pattern matches

### ECS Tasks Won't Start
- Check CloudWatch logs for container errors
- Verify VPC Endpoints exist (ECR, CloudWatch Logs)
- Check ECS security group allows outbound to VPC Endpoints

### Cross-Account ECR Pull Fails
- Verify ECR repository policy allows target account
- Check Task Execution Role has ECR pull permissions
- Ensure `ecr:GetAuthorizationToken` is allowed

---

## Architecture Summary

```
GitHub Actions (OIDC)
       │
       ▼
Tooling Account
├── OIDC Provider + GitHub Actions Role
├── ECR Repository (cross-account access)
├── S3 Bucket (Terraform state)
└── DynamoDB Table (state locking)
       │
       ├── AssumeRole → Dev Account
       │                 ├── ECS Cluster
       │                 ├── ECS Service
       │                 ├── ALB
       │                 └── DynamoDB (app data)
       │
       ├── AssumeRole → Staging Account
       │                 └── (same structure)
       │
       └── AssumeRole → Prod Account
                        └── (same structure, higher capacity)
```

---

## Next Steps

After successful deployment:

1. **Add HTTPS:** Configure ACM certificate and HTTPS listener
2. **Add WAF:** Web Application Firewall for production
3. **Add Monitoring:** CloudWatch dashboards and alarms
4. **Add Blue/Green:** CodeDeploy for zero-downtime deployments

---

### END OF DEPLOYMENT GUIDE
