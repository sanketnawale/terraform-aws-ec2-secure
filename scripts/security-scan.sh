#!/bin/bash
set -e

echo "🔒 Running security scans..."

# Install tools if not present
command -v tfsec >/dev/null 2>&1 || { echo "Installing tfsec..."; curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash; }
command -v checkov >/dev/null 2>&1 || { echo "Installing checkov..."; pip3 install checkov; }

cd terraform/

echo "📊 Running tfsec scan..."
tfsec . --config-file=../.tfsec.yml --format=json --out=../reports/tfsec-report.json
tfsec . --config-file=../.tfsec.yml

echo "🔍 Running Checkov scan..."
checkov -f . --config-file=../.checkov.yml --output=json --output-file=../reports/checkov-report.json
checkov -f . --config-file=../.checkov.yml

echo "✅ Security scans completed!"

