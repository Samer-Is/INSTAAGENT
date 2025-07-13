# Azure Infrastructure Setup

## Required Azure Resources

This document outlines the Azure resources needed for the Instagram AI Agent SaaS Platform.

### Resource Group
- **Name**: `rg-insta-ai-agent`
- **Location**: East US (or preferred region)

### Core Services

#### 1. Azure Cosmos DB
- **Service**: Azure Cosmos DB
- **API**: NoSQL (Core SQL)
- **Database Name**: `insta-ai-agent-db`
- **Containers**:
  - `whitelist` - Admin-controlled merchant whitelist
  - `merchants` - Merchant configurations and settings
  - `orders` - Order data from conversations
  - `conversations` - Message logs and analytics
  - `knowledge-base` - RAG content indexing

#### 2. Azure Key Vault
- **Service**: Azure Key Vault
- **Name**: `kv-insta-ai-agent`
- **Purpose**: Store Instagram access tokens and sensitive configuration
- **Access Policies**: App Service managed identity

#### 3. Azure OpenAI Service
- **Service**: Azure OpenAI
- **Model**: GPT-4o
- **Deployment Name**: `gpt-4o-deployment`
- **Purpose**: AI conversation generation

#### 4. Azure App Service
- **Service**: Azure App Service
- **Plan**: Basic B1 (or higher)
- **Runtime**: Node.js 18 LTS
- **Purpose**: Backend API and webhook endpoints
- **Environment Variables**:
  - `ADMIN_USERNAME`: Admin login username
  - `ADMIN_PASSWORD`: Admin login password (secure)
  - `COSMOS_DB_CONNECTION_STRING`: Cosmos DB connection
  - `AZURE_OPENAI_ENDPOINT`: OpenAI service endpoint
  - `AZURE_OPENAI_API_KEY`: OpenAI API key
  - `KEY_VAULT_URL`: Key Vault URL

#### 5. Azure Blob Storage
- **Service**: Azure Storage Account
- **Type**: Standard LRS
- **Containers**:
  - `knowledge-base-files` - Uploaded documents for RAG
  - `media-files` - Instagram media processing

#### 6. Azure Cognitive Search
- **Service**: Azure Cognitive Search
- **Tier**: Basic
- **Purpose**: RAG knowledge base search indexing

#### 7. Azure Static Web Apps (Merchant)
- **Service**: Azure Static Web Apps
- **Name**: `swa-insta-ai-merchant`
- **Purpose**: Public merchant dashboard
- **Custom Domain**: merchant.yourdomain.com

#### 8. Azure Static Web Apps (Admin)
- **Service**: Azure Static Web Apps
- **Name**: `swa-insta-ai-admin`
- **Purpose**: Private admin dashboard
- **Custom Domain**: admin.yourdomain.com (private)

### Additional Services

#### 9. Azure Cognitive Services
- **Service**: Speech Services
- **Purpose**: Voice message transcription
- **Region**: Same as other resources

#### 10. Azure Communication Services (Optional)
- **Service**: Azure Communication Services
- **Purpose**: Email notifications for handover alerts

## Deployment Steps

### 1. Create Resource Group
```bash
az group create --name rg-insta-ai-agent --location eastus
```

### 2. Deploy Resources
Use Azure CLI or ARM templates to provision all resources in the resource group.

### 3. Configure Access Policies
- Set up managed identity for App Service
- Configure Key Vault access policies
- Set up RBAC for Cosmos DB and other services

### 4. Environment Configuration
- Add environment variables to App Service configuration
- Configure connection strings
- Set up secrets in Key Vault

### 5. GitHub Secrets
Add the following secrets to GitHub repository:
- `AZURE_WEBAPP_NAME`: App Service name
- `AZURE_WEBAPP_PUBLISH_PROFILE`: App Service publish profile
- `AZURE_STATIC_WEB_APPS_API_TOKEN_MERCHANT`: Merchant SWA deployment token
- `AZURE_STATIC_WEB_APPS_API_TOKEN_ADMIN`: Admin SWA deployment token
- `API_BASE_URL`: Backend API base URL
- `INSTAGRAM_APP_ID`: Instagram app ID for OAuth

## Security Considerations

1. **Key Vault**: All sensitive data stored in Key Vault
2. **Managed Identity**: App Service uses managed identity for Azure resource access
3. **HTTPS Only**: All services configured for HTTPS only
4. **Private Endpoints**: Consider private endpoints for production
5. **Network Security**: Configure appropriate firewall rules
6. **RBAC**: Implement least privilege access control

## Monitoring and Logging

1. **Application Insights**: Enable for App Service and Static Web Apps
2. **Log Analytics**: Centralized logging workspace
3. **Alerts**: Set up alerts for critical metrics
4. **Diagnostics**: Enable diagnostic settings for all services

## Cost Optimization

1. **Auto-scaling**: Configure appropriate scaling rules
2. **Reserved Instances**: Consider reserved capacity for predictable workloads
3. **Monitoring**: Regular cost monitoring and optimization
4. **Cleanup**: Automated cleanup of unused resources 