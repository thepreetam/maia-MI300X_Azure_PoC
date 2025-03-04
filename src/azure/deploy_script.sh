#!/bin/bash
# Azure NDv5 MI350X Deployment Script
# This script deploys the MI350X VM using the ARM template

set -e

# Default values
RESOURCE_GROUP="maia-mi350x-rg"
LOCATION="eastus"
VM_SIZE="Standard_ND96amsr_v5"
ADMIN_USERNAME="azureuser"
SSH_KEY_FILE="$HOME/.ssh/id_rsa.pub"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --resource-group|-g)
      RESOURCE_GROUP="$2"
      shift
      shift
      ;;
    --location|-l)
      LOCATION="$2"
      shift
      shift
      ;;
    --vm-size|-s)
      VM_SIZE="$2"
      shift
      shift
      ;;
    --admin-username|-u)
      ADMIN_USERNAME="$2"
      shift
      shift
      ;;
    --ssh-key|-k)
      SSH_KEY_FILE="$2"
      shift
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --resource-group, -g    Resource group name (default: maia-mi350x-rg)"
      echo "  --location, -l          Azure region (default: eastus)"
      echo "  --vm-size, -s           VM size (default: Standard_ND96amsr_v5)"
      echo "  --admin-username, -u    Admin username (default: azureuser)"
      echo "  --ssh-key, -k           SSH public key file (default: ~/.ssh/id_rsa.pub)"
      echo "  --help, -h              Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if resource group exists, create if not
if ! az group show --name "$RESOURCE_GROUP" &>/dev/null; then
  echo "Creating resource group $RESOURCE_GROUP in $LOCATION..."
  az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
fi

# Check if SSH key file exists
if [ ! -f "$SSH_KEY_FILE" ]; then
  echo "Error: SSH key file not found: $SSH_KEY_FILE"
  exit 1
fi

# Deploy the ARM template
echo "Deploying MI350X VM to resource group $RESOURCE_GROUP..."
az deployment group create \
  --resource-group "$RESOURCE_GROUP" \
  --template-file "$(dirname "$0")/ndv5_deploy.json" \
  --parameters adminUsername="$ADMIN_USERNAME" \
  --parameters sshPublicKey="$(cat $SSH_KEY_FILE)" \
  --parameters vmSize="$VM_SIZE" \
  --parameters region="$LOCATION"

# Get the public IP address
echo "Deployment completed. Getting VM details..."
PUBLIC_IP=$(az deployment group show \
  --resource-group "$RESOURCE_GROUP" \
  --name "ndv5_deploy" \
  --query "properties.outputs.publicIPAddress.value" \
  --output tsv)

echo "MI350X VM deployed successfully!"
echo "Connect using: ssh $ADMIN_USERNAME@$PUBLIC_IP"
echo "Note: It may take a few minutes for the VM to be fully provisioned and accessible." 