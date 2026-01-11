# GitHub Variables Setup Guide

## Problem
Terraform hangs waiting for input because `terraform.tfvars` is gitignored and doesn't exist in the repository.

## Solution
Set up GitHub Repository Variables with values from your Day-0 CloudFormation StackSet outputs.

---

## Step 1: Get CloudFormation Stack Outputs

### For Dev Account:
```bash
# Switch to Dev profile
export AWS_PROFILE=Dev

# Get the stack name
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[?contains(StackName, 'day0')].StackName" --output text

# Get outputs (replace <stack-name> with actual name)
aws cloudformation describe-stacks --stack-name "<stack-name>" --query "Stacks[0].Outputs" --output table
```

### For Staging Account:
```bash
export AWS_PROFILE=Staging
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[?contains(StackName, 'day0')].StackName" --output text
aws cloudformation describe-stacks --stack-name "<stack-name>" --query "Stacks[0].Outputs" --output table
```

### For Prod Account:
```bash
export AWS_PROFILE=Prod
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query "StackSummaries[?contains(StackName, 'day0')].StackName" --output text
aws cloudformation describe-stacks --stack-name "<stack-name>" --query "Stacks[0].Outputs" --output table
```

---

## Step 2: Create GitHub Repository Variables

Go to your GitHub repository:
1. Click **Settings** → **Secrets and variables** → **Actions**
2. Click the **Variables** tab
3. Click **New repository variable**

### Dev Environment Variables

| Variable Name | Value Source | Example |
|---------------|--------------|---------|
| `DEV_VPC_ID` | VpcId output | `vpc-0a1b2c3d4e5f6g7h8` |
| `DEV_PUBLIC_SUBNET_1` | PublicSubnet1Id output | `subnet-0a1b2c3d` |
| `DEV_PUBLIC_SUBNET_2` | PublicSubnet2Id output | `subnet-4e5f6g7h` |
| `DEV_PRIVATE_SUBNET_1` | PrivateSubnet1Id output | `subnet-8i9j0k1l` |
| `DEV_PRIVATE_SUBNET_2` | PrivateSubnet2Id output | `subnet-2m3n4o5p` |
| `DEV_ALB_SG_ID` | AlbSecurityGroupId output | `sg-0a1b2c3d4e5f6g7h8` |

### Staging Environment Variables

| Variable Name | Value Source |
|---------------|--------------|
| `STAGING_VPC_ID` | VpcId output |
| `STAGING_PUBLIC_SUBNET_1` | PublicSubnet1Id output |
| `STAGING_PUBLIC_SUBNET_2` | PublicSubnet2Id output |
| `STAGING_PRIVATE_SUBNET_1` | PrivateSubnet1Id output |
| `STAGING_PRIVATE_SUBNET_2` | PrivateSubnet2Id output |
| `STAGING_ALB_SG_ID` | AlbSecurityGroupId output |

### Prod Environment Variables (3 AZs)

| Variable Name | Value Source |
|---------------|--------------|
| `PROD_VPC_ID` | VpcId output |
| `PROD_PUBLIC_SUBNET_1` | PublicSubnet1Id output |
| `PROD_PUBLIC_SUBNET_2` | PublicSubnet2Id output |
| `PROD_PUBLIC_SUBNET_3` | PublicSubnet3Id output |
| `PROD_PRIVATE_SUBNET_1` | PrivateSubnet1Id output |
| `PROD_PRIVATE_SUBNET_2` | PrivateSubnet2Id output |
| `PROD_PRIVATE_SUBNET_3` | PrivateSubnet3Id output |
| `PROD_ALB_SG_ID` | AlbSecurityGroupId output |

---

## Step 3: Verify Setup

After adding all variables, push your updated workflows to GitHub:

```bash
git add .github/workflows/
git commit -m "fix: Add required Terraform variables to workflows"
git push
```

The workflows will now pass all required variables to Terraform, preventing the hang.

---

## Alternative: Use terraform.tfvars Locally

For local development, create `terraform.tfvars` in each environment directory:

```bash
# Dev
cp infrastructure/environments/dev/terraform.tfvars.example infrastructure/environments/dev/terraform.tfvars

# Edit and fill in actual values
nano infrastructure/environments/dev/terraform.tfvars
```

**Note:** Never commit `terraform.tfvars` to Git (it's already in `.gitignore`).
