# Azure NDv5 Deployment Guide

This document provides instructions for deploying MI300X instances on Azure using the ARM template and configuring GitHub Secrets for CI/CD integration.

## GitHub Secrets Configuration

### Step 1: Create a service principal in Azure

```bash
az ad sp create-for-rbac --name "Maia-MI300X-Deploy" --role Contributor --scopes /subscriptions/<YOUR_SUB_ID>
```

### Step 2: Add these secrets to your GitHub repo (Settings → Secrets → Actions)

- **Name**: `AZURE_CREDS`  
  **Value**:  
  ```json
  {
    "clientId": "<SP_CLIENT_ID>",
    "clientSecret": "<SP_CLIENT_SECRET>",
    "subscriptionId": "<SUBSCRIPTION_ID>",
    "tenantId": "<TENANT_ID>"
  }
  ```

- **Name**: `AZURE_PASSWORD`  
  **Value**: `<SP_CLIENT_SECRET>`

## Key Features

### 1. ARM Template
- Auto-deploys MI300X instances with pre-installed AMD ROCm drivers
- Runs latency benchmarks on startup via `CustomScript` extension
- Uses **Standard_ND96amsr_v5** – Azure's MI300X VM SKU

### 2. GitHub Secrets
- Allows CI/CD to authenticate with Azure and validate deployments
- Matches the `deploy_script.sh` workflow from the PoC branch

## Benchmark Script Details

The ARM template includes a Base64-encoded script that runs on VM startup. When decoded, it contains:

```bash
# Install AMD ROCm and run benchmarks
sudo apt-get update -qy
sudo apt-get install -qy rocm-kit_all
git clone https://github.com/thepreetam/maia_fractal_edge_encoder.git
cd maia_fractal_edge_encoder
python benchmarks/latency_test.py --target 0.5ms
```

## Testing the Deployment

You can test the deployment using the Azure CLI:

```bash
az deployment group create --template-file azure/ndv5_deploy.json \
  --parameters adminUsername=azureuser \
  --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
  --resource-group my-mi300x-test
``` 