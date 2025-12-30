# Terraform Setup for Minecraft Server on AWS

This guide documents all steps required to set up and manage a Minecraft server on AWS using Terraform, including creating the VPC, subnets, security groups, and EC2 instance.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Terraform Directory Structure](#terraform-directory-structure)
3. [Initialize Terraform](#initialize-terraform)
4. [Plan and Apply Infrastructure](#plan-and-apply-infrastructure)
5. [Managing EC2 Key Pair](#managing-ec2-key-pair)
6. [Destroying Resources](#destroying-resources)
7. [Recreating Specific Resources](#recreating-specific-resources)
8. [Best Practices](#best-practices)

## Prerequisites
- AWS account with access to EC2, VPC, IAM, and Key Pairs
- Terraform installed (v1.6+)
- AWS CLI configured with credentials
- Git installed
- Basic knowledge of Terraform resources and modules

## Terraform Directory Structure
```
├── dev
│   ├── main.tf
│   ├── modules
│   │   ├── ec2
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── networking
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── security-group
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   └── variables.tf
└── prod
    ├── main.tf
    ├── modules
    │   ├── ec2
    │   ├── networking
    │   └── security-group
    ├── outputs.tf
    ├── provider.tf
    ├── terraform.tfvars
    └── variables.tf

```

> **Note:** The `.terraform/` folder, `terraform.tfstate`, and Terraform provider binaries **should never be committed to Git**.

## Initialize Terraform
1. Navigate to your environment folder:
```bash
cd infra/env/dev
```

2. Initialize Terraform:
```bash
terraform init
```
- Downloads required providers and modules  
- Prepares your backend and local workspace

## Plan and Apply Infrastructure
1. Plan your changes:
```bash
terraform plan
```
- Review the output to ensure the correct resources will be created

2. Apply changes:
```bash
terraform apply
```
- Enter `yes` when prompted to confirm  
- Terraform will provision all resources defined in your modules:
  - VPC, subnets, route tables
  - Security groups
  - EC2 instance for Minecraft

3. Get outputs:
```bash
terraform output minecraft_ec2_public_ip
```
- Shows the public IP of your Minecraft server


## Managing EC2 Key Pair
Terraform requires an AWS Key Pair for SSH access.

1. Create a key pair via AWS CLI:
```bash
aws ec2 create-key-pair --key-name minecraft-keypair --query 'KeyMaterial' --output text > minecraft-keypair.pem
chmod 400 minecraft-keypair.pem
```

2. Reference the key pair in `ec2/main.tf`:
```hcl
key_name = "minecraft-keypair"
```
> Terraform does not automatically create key pairs unless defined explicitly in a resource block.


## Destroying Resources
1. Destroy all resources in the environment:
```bash
terraform destroy
```
- Enter `yes` to confirm destruction

2. Destroy a specific resource (e.g., EC2 instance only):
```bash
terraform destroy -target=module.minecraft_ec2.aws_instance.minecraft_ec2
```
- Only the targeted resource will be destroyed, leaving other resources intact


## Recreating Specific Resources
1. Recreate resources defined in `.tf` files that do not exist in state:
```bash
terraform apply
```

> ⚠️ If the resource exists in AWS but is not in Terraform state, Terraform may try to create a duplicate. Use:
```bash
terraform import <resource> <aws-resource-id>
```
to sync existing resources into Terraform state before applying.


## Best Practices
- Ignore sensitive and large files in Git:
```gitignore
.terraform/
*.tfstate
*.tfstate.backup
*.pem
```
- Use `terraform plan` before `apply` to prevent accidental changes  
- Keep Terraform modules modular for easy reuse and updates  
- Commit only code, not provider binaries or state files  

This README ensures a smooth setup and management workflow for your AWS-based Minecraft server using Terraform.