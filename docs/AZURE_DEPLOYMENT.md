# Azure Deployment Guide

## Overview

This document provides instructions for deploying MI350X instances on Azure using the ARM template and configuring GitHub Secrets for CI/CD integration.

## Prerequisites

1. Azure subscription with access to NDv5 instances
2. Azure CLI installed and configured
3. GitHub repository with Actions enabled

## Setting Up Azure Service Principal

1. Create a service principal with Contributor role:
```bash
az ad sp create-for-rbac --name "Maia-MI350X-Deploy" --role Contributor --scopes /subscriptions/<YOUR_SUB_ID>
```

2. Save the output JSON for GitHub Secrets configuration.

## Resource Group Setup

1. Create a resource group:
```bash
az group create --name "maia-mi350x-rg" --location "eastus"
```

## ARM Template Deployment

The project includes an ARM template (`src/azure/ndv5_deploy.json`) that:
- Auto-deploys MI350X instances with pre-installed AMD ROCm drivers
- Configures networking and security groups
- Uses **Standard_ND96amsr_v5** – Azure's MI350X VM SKU

### Manual Deployment

1. Deploy using ARM template:
```bash
az deployment group create \
  --resource-group "maia-mi350x-rg" \
  --template-file "src/azure/ndv5_deploy.json" \
  --parameters adminUsername="azureuser" \
  --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
```

2. Get the public IP:
```bash
az network public-ip show \
  --resource-group "maia-mi350x-rg" \
  --name "maia-public-ip" \
  --query ipAddress \
  --output tsv
```

### Automated Deployment

1. Configure GitHub Secrets (see [GITHUB_SECRETS.md](GITHUB_SECRETS.md))
2. Push changes to trigger CI/CD pipeline
3. Monitor deployment in GitHub Actions

## Post-Deployment

1. SSH into the VM:
```bash
ssh azureuser@<PUBLIC_IP>
```

2. Verify ROCm installation:
```bash
rocm-smi
```

3. Run benchmarks:
```bash
cd maia-mi350x-poc
python src/benchmarks/latency_test.py
```

## Troubleshooting

### Common Issues

1. **VM Not Starting**
   - Check resource quotas
   - Verify subscription has NDv5 access
   - Review VM logs in Azure Portal

2. **ROCm Installation Failures**
   - Check AMD driver compatibility
   - Review system logs
   - Verify kernel version

3. **Network Issues**
   - Check NSG rules
   - Verify subnet configuration
   - Test network connectivity

### Support

For issues:
1. Check [GitHub Issues](https://github.com/your-org/maia-mi350x-poc/issues)
2. Contact Azure support
3. Review [MI350X documentation](https://rocmdocs.amd.com)

## Cost Management

1. Monitor usage in Azure Portal
2. Set up cost alerts
3. Review [AZURE_COST_MODEL.md](AZURE_COST_MODEL.md)

## Security

1. Follow least privilege principle
2. Rotate credentials regularly
3. Monitor access logs
4. Keep systems updated 