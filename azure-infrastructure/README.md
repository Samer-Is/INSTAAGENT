# Azure Infrastructure Deployment

This directory contains all the necessary files to deploy the complete Azure infrastructure for the Instagram AI Agent SaaS Platform from scratch.

## 📋 Prerequisites

1. **Azure CLI** - [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Azure Subscription** - Active Azure subscription with appropriate permissions
3. **Instagram Developer Account** - For App ID and App Secret
4. **PowerShell** (Windows) or **Bash** (Linux/Mac) - For running deployment scripts

## 🏗️ Infrastructure Components

The deployment will create the following Azure resources:

### Core Services
- **Azure Cosmos DB** - NoSQL database with 5 containers (whitelist, merchants, orders, conversations, knowledge-base)
- **Azure Key Vault** - Secure storage for Instagram access tokens and secrets
- **Azure OpenAI Service** - GPT-4o deployment for AI conversations
- **Azure App Service** - Backend API and webhook endpoints
- **Azure Static Web Apps** - Two separate frontends (merchant & admin)

### Supporting Services
- **Azure Blob Storage** - File storage for knowledge base documents and media
- **Azure Cognitive Search** - RAG knowledge base search indexing
- **Azure Cognitive Services** - Speech-to-text for voice message transcription
- **App Service Plan** - Hosting plan for the backend service

### Security & Access
- **Managed Identity** - App Service system-assigned identity
- **RBAC Assignments** - Proper role assignments for secure access
- **HTTPS Only** - All services configured for secure communication

## 🚀 Deployment Instructions

### Step 1: Prepare Required Information

Before deployment, gather the following information:

1. **Azure Subscription ID** - Find this in the Azure Portal
2. **Admin Password** - Strong password for platform admin access
3. **Instagram App ID** - From Meta Developer Console
4. **Instagram App Secret** - From Meta Developer Console
5. **Webhook Verify Token** - Generate a random string for webhook verification

### Step 2: Deploy Infrastructure

#### Option A: PowerShell (Windows)

```powershell
cd azure-infrastructure

# Run the deployment script
.\deploy.ps1 -SubscriptionId "YOUR_SUBSCRIPTION_ID" `
             -AdminPassword "YOUR_ADMIN_PASSWORD" `
             -InstagramAppId "YOUR_INSTAGRAM_APP_ID" `
             -InstagramAppSecret "YOUR_INSTAGRAM_APP_SECRET" `
             -WebhookVerifyToken "YOUR_WEBHOOK_VERIFY_TOKEN"
```

#### Option B: Bash (Linux/Mac)

```bash
cd azure-infrastructure

# Make script executable (if not already)
chmod +x deploy.sh

# Run the deployment script
./deploy.sh --subscription-id "YOUR_SUBSCRIPTION_ID" \
           --admin-password "YOUR_ADMIN_PASSWORD" \
           --instagram-app-id "YOUR_INSTAGRAM_APP_ID" \
           --instagram-app-secret "YOUR_INSTAGRAM_APP_SECRET" \
           --webhook-verify-token "YOUR_WEBHOOK_VERIFY_TOKEN"
```

#### Optional Parameters

Both scripts support optional parameters:

- `--resource-group` / `-ResourceGroupName`: Custom resource group name (default: `rg-insta-ai-agent-dev`)
- `--location` / `-Location`: Azure region (default: `East US`)

### Step 3: Deployment Output

After successful deployment, you'll receive:

1. **Resource URLs**:
   - Backend API URL
   - Merchant Dashboard URL
   - Admin Dashboard URL

2. **Azure Resource Names**:
   - All created resource names with unique suffixes

3. **Deployment Output File**: `deployment-outputs.json` containing all resource information

## 🔧 Post-Deployment Configuration

### 1. Configure GitHub Secrets

Add the following secrets to your GitHub repository:

```bash
# Get the deployment outputs
cat deployment-outputs.json

# Add these secrets to GitHub repository settings:
AZURE_WEBAPP_NAME=<appServiceName>
AZURE_WEBAPP_PUBLISH_PROFILE=<download from Azure Portal>
AZURE_STATIC_WEB_APPS_API_TOKEN_MERCHANT=<from Azure Portal>
AZURE_STATIC_WEB_APPS_API_TOKEN_ADMIN=<from Azure Portal>
API_BASE_URL=<backendUrl>
INSTAGRAM_APP_ID=<your_instagram_app_id>
```

### 2. Update Environment Variables

Update the frontend environment files with the deployed backend URL:

```bash
# frontend-merchant/.env
VITE_API_BASE_URL=<backendUrl>/api

# frontend-admin/.env
VITE_API_BASE_URL=<backendUrl>/api
```

### 3. Configure Instagram Webhook

In the Meta Developer Console, set the webhook URL to:
```
<backendUrl>/api/webhooks/instagram
```

## 📊 Resource Monitoring

### Cost Estimation

The deployed resources will incur the following approximate monthly costs:

- **Azure Cosmos DB (Serverless)**: $0-50 depending on usage
- **Azure OpenAI Service**: $0-100 depending on API calls
- **Azure App Service (Basic B1)**: ~$13
- **Azure Static Web Apps**: Free tier
- **Azure Cognitive Search (Basic)**: ~$250
- **Azure Storage**: $0-5 depending on usage
- **Azure Key Vault**: $0-5 depending on usage

**Total Estimated Cost**: $270-420/month

### Monitoring and Logging

All services are configured with:
- Application Insights for monitoring
- Diagnostic logging enabled
- Performance metrics collection
- Error tracking and alerts

## 🔒 Security Considerations

- All secrets stored in Azure Key Vault
- Managed Identity used for service-to-service authentication
- HTTPS enforced on all endpoints
- RBAC with least privilege access
- Network security groups configured appropriately

## 🛠️ Troubleshooting

### Common Issues

1. **Deployment Fails**: Check Azure CLI version and login status
2. **Permission Errors**: Ensure proper Azure subscription permissions
3. **Resource Name Conflicts**: Unique suffixes are generated automatically
4. **Region Availability**: Some services may not be available in all regions

### Support

For deployment issues:
1. Check the deployment logs in Azure Portal
2. Verify all required parameters are provided
3. Ensure Azure CLI is properly authenticated
4. Check resource quotas and limits

## 🗑️ Cleanup

To remove all resources:

```bash
# Delete the entire resource group
az group delete --name "rg-insta-ai-agent-dev" --yes --no-wait
```

⚠️ **Warning**: This will permanently delete all resources and data.

## 📚 Next Steps

After successful deployment:

1. ✅ Infrastructure deployed
2. ⏳ Configure CI/CD pipeline
3. ⏳ Deploy application code
4. ⏳ Test end-to-end functionality
5. ⏳ Configure Instagram webhook
6. ⏳ Begin Phase 1 development

---

*This deployment follows the Instagram AI Agent SaaS Platform development instructions and creates all Azure resources from scratch as specified in Phase 0.* 