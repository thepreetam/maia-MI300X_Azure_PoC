# GitHub Secrets Configuration for MI350X CI/CD

## Overview

This document provides instructions for setting up the GitHub Secrets required for the MI350X CI/CD pipeline.

## Required Secrets

### Azure Service Principal

1. Create an Azure service principal with Contributor role:
```bash
az ad sp create-for-rbac --name "Maia-MI350X-Deploy" --role Contributor --scopes /subscriptions/<YOUR_SUB_ID>
```

2. The command will output JSON like this:
```json
{
  "appId": "<APP_ID>",
  "displayName": "Maia-MI350X-Deploy",
  "name": "http://Maia-MI350X-Deploy",
  "password": "<PASSWORD>",
  "tenant": "<TENANT_ID>"
}
```

3. Add these values to your GitHub repository secrets:
   - `AZURE_CLIENT_ID`: The `appId` value
   - `AZURE_CLIENT_SECRET`: The `password` value
   - `AZURE_TENANT_ID`: The `tenant` value
   - `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID

### Resource Group

1. Create a resource group for the deployment:
```bash
az group create --name "maia-mi350x-rg" --location "eastus"
```

2. Add the resource group name to your GitHub repository secrets:
   - `AZURE_RESOURCE_GROUP`: "maia-mi350x-rg"

### Additional Configuration

1. Set the deployment location:
   - `AZURE_LOCATION`: "eastus"

2. Set the VM size:
   - `AZURE_VM_SIZE`: "Standard_ND96amsr_v5"

## Usage in GitHub Actions

These secrets are used in the CI/CD workflow (`.github/workflows/mi350x-ci.yml`):

```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- name: Deploy ARM Template
  run: |
    az deployment group create \
      --resource-group ${{ secrets.AZURE_RESOURCE_GROUP }} \
      --template-file src/azure/ndv5_deploy.json \
      --parameters adminUsername=${{ secrets.AZURE_ADMIN_USERNAME }} \
      --parameters sshPublicKey="${{ secrets.AZURE_SSH_PUBLIC_KEY }}"
```

## Security Notes

1. Never commit secrets to the repository
2. Rotate service principal credentials regularly
3. Use the principle of least privilege when assigning roles
4. Monitor secret usage in GitHub Actions logs 