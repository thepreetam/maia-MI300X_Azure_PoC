# GitHub Secrets Configuration for MI300X CI/CD

This document provides instructions for setting up the GitHub Secrets required for the MI300X CI/CD pipeline.

## Required Secrets

The CI/CD pipeline requires the following secrets to be configured in your GitHub repository:

1. **AZURE_CREDS**: JSON object containing Azure service principal credentials
2. **AZURE_PASSWORD**: The service principal client secret

## Setting Up Azure Service Principal

Before configuring the GitHub Secrets, you need to create an Azure service principal with the appropriate permissions:

```bash
az ad sp create-for-rbac --name "Maia-MI300X-Deploy" --role Contributor --scopes /subscriptions/<YOUR_SUB_ID>
```

This command will output JSON similar to:

```json
{
  "appId": "<APP_ID>",
  "displayName": "Maia-MI300X-Deploy",
  "password": "<PASSWORD>",
  "tenant": "<TENANT_ID>"
}
```

## Configuring GitHub Secrets

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click on **New repository secret**

### Secret 1: AZURE_CREDS

- **Name**: `AZURE_CREDS`
- **Value**:
  ```json
  {
    "clientId": "<APP_ID>",
    "clientSecret": "<PASSWORD>",
    "subscriptionId": "<SUBSCRIPTION_ID>",
    "tenantId": "<TENANT_ID>"
  }
  ```

Replace the placeholders with the values from the service principal creation output:
- `<APP_ID>` with the `appId` value
- `<PASSWORD>` with the `password` value
- `<TENANT_ID>` with the `tenant` value
- `<SUBSCRIPTION_ID>` with your Azure subscription ID

### Secret 2: AZURE_PASSWORD

- **Name**: `AZURE_PASSWORD`
- **Value**: `<PASSWORD>`

Use the same `password` value from the service principal creation output.

## Verifying Configuration

After configuring the secrets, you can verify they are set up correctly by:

1. Going to the **Actions** tab in your repository
2. Running the CI/CD workflow manually
3. Checking that the "Azure NDv5 Deployment Dry-Run" step completes successfully

## Security Considerations

- The service principal credentials provide access to your Azure resources, so keep them secure
- Consider setting an expiration date for the service principal
- Use the principle of least privilege by limiting the scope of the service principal to only the resources needed 