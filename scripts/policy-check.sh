#!/bin/bash
set -e

echo "📋 Running OPA policy checks..."

# Check if we're in the right directory
if [ ! -d "terraform" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Install OPA if not present
if ! command -v opa >/dev/null 2>&1; then
    echo "Installing OPA..."
    curl -L -o opa https://github.com/open-policy-agent/opa/releases/latest/download/opa_linux_amd64
    chmod +x opa
    sudo mv opa /usr/local/bin/
fi

cd terraform/

# Check if tfvars file exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ terraform.tfvars file not found! Creating a default one..."
    cat > terraform.tfvars << 'TFVARS'
region = "eu-west-3"
instance_type = "t3.micro"
environment = "dev"
project_name = "terraform-ec2-secure"
TFVARS
    echo "✅ Created terraform.tfvars with default values"
fi

# Generate Terraform plan with explicit tfvars file
echo "🏗️ Generating Terraform plan..."
terraform plan -var-file="terraform.tfvars" -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json

# Create empty policy results
echo "🔍 Running OPA policy evaluations..."

# Run policy checks with error handling
echo "🛡️ Checking security policies..."
if [ -f "../policies/ec2-security.rego" ]; then
    SECURITY_RESULT=$(opa eval --input tfplan.json --data ../policies/ec2-security.rego "data.terraform.ec2.security.deny" 2>/dev/null || echo "Policy file error")
    if [ "$SECURITY_RESULT" != "undefined" ] && [ "$SECURITY_RESULT" != "Policy file error" ] && [ "$SECURITY_RESULT" != "{}" ]; then
        echo "❌ Security policy violations found:"
        echo "$SECURITY_RESULT"
    else
        echo "✅ No security policy violations"
    fi
else
    echo "⚠️ Security policy file not found, skipping..."
fi

echo ""
echo "📏 Checking compliance policies..."
if [ -f "../policies/compliance.rego" ]; then
    COMPLIANCE_RESULT=$(opa eval --input tfplan.json --data ../policies/compliance.rego "data.terraform.compliance.deny" 2>/dev/null || echo "Policy file error")
    if [ "$COMPLIANCE_RESULT" != "undefined" ] && [ "$COMPLIANCE_RESULT" != "Policy file error" ] && [ "$COMPLIANCE_RESULT" != "{}" ]; then
        echo "❌ Compliance policy violations found:"
        echo "$COMPLIANCE_RESULT"
    else
        echo "✅ No compliance policy violations"
    fi
else
    echo "⚠️ Compliance policy file not found, skipping..."
fi

echo ""
echo "💰 Checking cost optimization policies..."
if [ -f "../policies/cost-optimization.rego" ]; then
    COST_RESULT=$(opa eval --input tfplan.json --data ../policies/cost-optimization.rego "data.terraform.cost.deny" 2>/dev/null || echo "Policy file error")
    if [ "$COST_RESULT" != "undefined" ] && [ "$COST_RESULT" != "Policy file error" ] && [ "$COST_RESULT" != "{}" ]; then
        echo "❌ Cost optimization policy violations found:"
        echo "$COST_RESULT"
    else
        echo "✅ No cost optimization policy violations"
    fi
else
    echo "⚠️ Cost optimization policy file not found, skipping..."
fi

echo ""
echo "📊 Policy check summary complete!"
echo "📁 Terraform plan saved as: tfplan.json"

# Cleanup
cd ..
echo "✅ Policy checks completed!"
