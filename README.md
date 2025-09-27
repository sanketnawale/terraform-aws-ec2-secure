# Terraform AWS EC2 Secure - Enterprise DevSecOps Implementation

A comprehensive Infrastructure as Code (IaC) project demonstrating how to build secure, compliant, and cost-optimized AWS infrastructure using Terraform with automated policy enforcement and security scanning.

## Project Overview

This project transforms basic infrastructure automation into "trustworthy automation" by integrating security scanning, policy-as-code validation, and compliance checks directly into the infrastructure deployment pipeline.

**What This Project Does:**
- Deploys secure AWS EC2 infrastructure using Terraform
- Enforces security, compliance, and cost policies automatically
- Scans infrastructure code for vulnerabilities before deployment  
- Demonstrates enterprise-grade DevSecOps practices
- Provides a complete CI/CD ready workflow

## Problem Solved

Most infrastructure deployments focus only on functionality. This project addresses critical enterprise needs:

1. **Security by Default**: Prevents insecure configurations from being deployed
2. **Cost Control**: Automatically blocks expensive resource configurations
3. **Compliance Automation**: Ensures all resources meet organizational standards
4. **Risk Reduction**: Catches security vulnerabilities before they reach production
5. **Standardization**: Provides a reusable template for secure infrastructure

## Architecture and Components

### Infrastructure Components (AWS)
- **EC2 Instance**: t3.micro instance with security hardening
- **Security Group**: Network access controls with restricted permissions
- **EBS Volume**: Encrypted root storage with appropriate sizing
- **IAM Integration**: Secure instance metadata service configuration

### Security Features Implemented
- **Encryption**: All data encrypted at rest using AWS managed keys
- **IMDSv2 Enforcement**: Prevents instance metadata service attacks
- **Network Security**: No public IP assignment, restricted security group rules
- **Monitoring**: CloudWatch integration for instance tracking
- **Access Control**: SSH access can be restricted to specific IP addresses

### Policy as Code Implementation
- **Security Policies**: Prevent insecure configurations (public IPs, unencrypted storage)
- **Compliance Policies**: Enforce required tagging and naming conventions
- **Cost Policies**: Restrict expensive instance types and oversized storage
- **Automated Validation**: All policies checked before deployment

### Security Scanning Integration
- **tfsec**: Static analysis of Terraform code for security issues
- **Checkov**: Policy compliance and security scanning
- **OPA/Rego**: Custom policy engine for organization-specific rules

## Project Structure

terraform-aws-ec2-secure/
├── terraform/ # Infrastructure as Code
│ ├── main.tf # Primary AWS resource definitions
│ ├── variables.tf # Input parameters with validation
│ ├── outputs.tf # Resource information outputs
│ ├── versions.tf # Terraform and provider requirements
│ └── terraform.tfvars.example # Configuration template
├── policies/ # Policy as Code rules
│ ├── ec2-security.rego # Security policy definitions
│ ├── compliance.rego # Compliance and governance rules
│ └── cost-optimization.rego # Cost control policies
├── scripts/ # Automation utilities
│ ├── security-scan.sh # Security scanning automation
│ └── policy-check.sh # Policy validation automation
├── docs/ # Project documentation
│ ├── SECURITY.md # Security implementation details
│ └── POLICIES.md # Policy documentation
└── .github/workflows/ # CI/CD pipeline (optional)
└── terraform-security.yml # Automated validation workflow



## Prerequisites

Before using this project, ensure you have:

1. **AWS Account**: Active AWS account with appropriate permissions
2. **AWS CLI**: Configured with valid credentials (`aws configure`)
3. **Terraform**: Version 1.5 or higher (`terraform --version`)
4. **Git**: For version control and repository management
5. **Basic Knowledge**: Understanding of AWS EC2, VPC, and security groups

### Required AWS Permissions
Your AWS user/role needs permissions for:
- EC2 instance creation and management
- Security group creation and modification
- EBS volume creation and encryption
- VPC access (using default VPC)

## Quick Start Guide

### Step 1: Clone the Repository
git clone https://github.com/sanketnawale/terraform-aws-ec2-secure.git
cd terraform-aws-ec2-secure



### Step 2: Configure Variables
Copy the example configuration file
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

Edit the configuration file with your preferences
vi terraform/terraform.tfvars



**Example Configuration:**
region = "us-west-2" # Your preferred AWS region
instance_type = "t3.micro" # Instance size (cost-optimized)
environment = "dev" # Environment name (dev/staging/prod)
project_name = "my-secure-project" # Project identifier



### Step 3: Install Dependencies (Optional)
Make scripts executable
chmod +x scripts/*.sh

Install security scanning tools (optional)
./scripts/security-scan.sh # This will install tools if missing



### Step 4: Validate Configuration
Initialize Terraform
cd terraform/
terraform init

Validate syntax and configuration
terraform validate

Review the planned changes
terraform plan



### Step 5: Run Security and Policy Checks
Return to project root
cd ..

Run security scanning
./scripts/security-scan.sh

Run policy validation
./scripts/policy-check.sh



### Step 6: Deploy Infrastructure
Deploy the infrastructure
cd terraform/
terraform apply

Review the changes and type 'yes' to confirm


### Step 7: Verify Deployment
After successful deployment, you will see outputs similar to:
instance_id = "i-0d81b243ab86cf314"
instance_type = "t3.micro"
private_ip = "172.31.43.178"
security_group_id = "sg-007b525d7c03667d8"



## Understanding the Security Implementation

### Network Security
- **Private Networking**: Instance receives only private IP addresses
- **Security Group Rules**: Minimal required access (HTTP/HTTPS/SSH)
- **SSH Restrictions**: Can be configured for specific IP address access
- **Outbound Access**: Controlled internet access for updates and package installation

### Data Protection
- **Encryption at Rest**: Root volume encrypted using AWS managed encryption
- **Instance Metadata**: IMDSv2 enforced to prevent credential theft attacks
- **Access Logging**: CloudWatch integration for access monitoring

### Policy Enforcement Examples

**Security Policy Example:**
Prevents deployment of instances with public IP addresses
deny contains msg if {
resource := input.resource_changes[_]
resource.type == "aws_instance"
resource.change.after.associate_public_ip_address == true
msg := "EC2 instances must not have public IP addresses for security"
}



**Cost Control Example:**
Restricts instance types to cost-effective options
allowed_instance_types := ["t3.micro", "t3.small", "t2.micro"]
deny contains msg if {
resource := input.resource_changes[_]
resource.type == "aws_instance"
not resource.change.after.instance_type in allowed_instance_types
msg := "Instance type not approved for cost optimization"
}



## Policy Validation Results

When you run the policy checks, you'll see results categorized as:

**Security Policies**: Validates security configurations
- Pass: No security violations detected
- Fail: Security issues found (e.g., public IP assigned, encryption disabled)

**Compliance Policies**: Checks organizational standards
- Pass: All required tags present, naming conventions followed  
- Fail: Missing required tags or incorrect naming

**Cost Policies**: Validates cost optimization
- Pass: Approved instance types and storage sizes
- Fail: Expensive configurations detected

## Customization Options

### Modifying Security Policies
Edit files in the `policies/` directory to customize rules:
- Add new security requirements
- Modify compliance standards
- Adjust cost control thresholds

### Infrastructure Modifications
Update `terraform/main.tf` to:
- Change instance specifications
- Modify network configurations
- Add additional AWS resources

### Environment Configurations  
Use different `.tfvars` files for multiple environments:
Development environment
terraform plan -var-file="dev.tfvars"

Production environment
terraform plan -var-file="prod.tfvars"



## Cleanup

To remove all created resources and avoid ongoing charges:

cd terraform/
terraform destroy

Type 'yes' when prompted to confirm deletion

This will safely remove all AWS resources created by this project.

## Troubleshooting

### Common Issues and Solutions

**Authentication Errors:**
- Verify AWS CLI configuration: `aws sts get-caller-identity`
- Check AWS credentials and permissions
- Ensure region is correctly specified

**Terraform Errors:**
- Run `terraform init` after cloning repository
- Check Terraform version compatibility
- Verify all required variables are set

**Policy Validation Failures:**
- Review policy error messages for specific issues
- Check that your configuration meets security requirements
- Modify policies if they're too restrictive for your use case

**Large File Upload Issues:**
- Ensure `.terraform/` directory is not committed to version control
- Check `.gitignore` includes all temporary files
- Remove any `*.tfstate` files before committing
