#!/bin/bash

# Azure DevOps Setup Script
# This script configures Azure DevOps CLI with your organization and project

set -e

echo "🚀 Setting up Azure DevOps CLI integration..."

# Check if Azure DevOps extension is installed
if ! az extension show --name azure-devops &> /dev/null; then
    echo "Installing Azure DevOps CLI extension..."
    az extension add --name azure-devops
fi

# Source environment variables
if [ -f ".env.azure-devops" ]; then
    echo "Loading Azure DevOps configuration..."
    source .env.azure-devops
else
    echo "❌ .env.azure-devops file not found!"
    echo "Please create this file with your Azure DevOps configuration:"
    echo "AZURE_DEVOPS_EXT_PAT=your_token"
    echo "AZURE_DEVOPS_ORG_URL=https://dev.azure.com/YourOrg"
    echo "AZURE_DEVOPS_PROJECT=YourProject"
    exit 1
fi

# Validate required environment variables
if [ -z "$AZURE_DEVOPS_EXT_PAT" ] || [ -z "$AZURE_DEVOPS_ORG_URL" ] || [ -z "$AZURE_DEVOPS_PROJECT" ]; then
    echo "❌ Missing required environment variables in .env.azure-devops"
    echo "Required: AZURE_DEVOPS_EXT_PAT, AZURE_DEVOPS_ORG_URL, AZURE_DEVOPS_PROJECT"
    exit 1
fi

# Export environment variables
export AZURE_DEVOPS_EXT_PAT
export AZURE_DEVOPS_ORG_URL  
export AZURE_DEVOPS_PROJECT

# Configure defaults
echo "Configuring Azure DevOps defaults..."
az devops configure --defaults organization="$AZURE_DEVOPS_ORG_URL" project="$AZURE_DEVOPS_PROJECT"

# Test connection
echo "Testing connection..."
if az boards work-item list --top 1 &> /dev/null; then
    echo "✅ Azure DevOps CLI configured successfully!"
    echo "Organization: $AZURE_DEVOPS_ORG_URL"
    echo "Project: $AZURE_DEVOPS_PROJECT"
else
    echo "❌ Failed to connect to Azure DevOps. Please check your configuration."
    exit 1
fi

echo "🎉 Setup complete! You can now use Azure DevOps CLI commands."