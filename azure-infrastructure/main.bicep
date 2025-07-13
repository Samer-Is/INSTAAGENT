// Instagram AI Agent SaaS Platform - Azure Infrastructure
// This template creates all required Azure resources from scratch

@description('The name of the project')
param projectName string = 'insta-ai-agent'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The environment (dev, staging, prod)')
param environment string = 'dev'

@description('Admin username for the platform')
@secure()
param adminUsername string

@description('Admin password for the platform')
@secure()
param adminPassword string

@description('Instagram App ID')
@secure()
param instagramAppId string

@description('Instagram App Secret')
@secure()
param instagramAppSecret string

@description('Webhook verify token')
@secure()
param webhookVerifyToken string

// Variables
var resourcePrefix = '${projectName}-${environment}'
var uniqueSuffix = uniqueString(resourceGroup().id)

// 1. COSMOS DB
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: '${resourcePrefix}-cosmos-${uniqueSuffix}'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosAccount
  name: 'insta-ai-agent-db'
  properties: {
    resource: {
      id: 'insta-ai-agent-db'
    }
  }
}

// Cosmos DB Containers
resource whitelistContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDatabase
  name: 'whitelist'
  properties: {
    resource: {
      id: 'whitelist'
      partitionKey: {
        paths: ['/pageId']
        kind: 'Hash'
      }
    }
  }
}

resource merchantsContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDatabase
  name: 'merchants'
  properties: {
    resource: {
      id: 'merchants'
      partitionKey: {
        paths: ['/pageId']
        kind: 'Hash'
      }
    }
  }
}

resource ordersContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDatabase
  name: 'orders'
  properties: {
    resource: {
      id: 'orders'
      partitionKey: {
        paths: ['/merchantId']
        kind: 'Hash'
      }
    }
  }
}

resource conversationsContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDatabase
  name: 'conversations'
  properties: {
    resource: {
      id: 'conversations'
      partitionKey: {
        paths: ['/pageId']
        kind: 'Hash'
      }
    }
  }
}

resource knowledgeBaseContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDatabase
  name: 'knowledge-base'
  properties: {
    resource: {
      id: 'knowledge-base'
      partitionKey: {
        paths: ['/merchantId']
        kind: 'Hash'
      }
    }
  }
}

// 2. KEY VAULT
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: '${resourcePrefix}-kv-${uniqueSuffix}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// 3. STORAGE ACCOUNT
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${take(replace(replace(resourcePrefix, '-', ''), '_', ''), 10)}${take(uniqueSuffix, 13)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Storage Containers
resource knowledgeBaseFilesContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/knowledge-base-files'
  properties: {
    publicAccess: 'None'
  }
}

resource mediaFilesContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/media-files'
  properties: {
    publicAccess: 'None'
  }
}

// 4. COGNITIVE SEARCH
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: '${resourcePrefix}-search-${uniqueSuffix}'
  location: location
  sku: {
    name: 'basic'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
  }
}

// 5. COGNITIVE SERVICES (Speech)
resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: '${resourcePrefix}-speech-${uniqueSuffix}'
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'SpeechServices'
  properties: {
    customSubDomainName: '${resourcePrefix}-speech-${uniqueSuffix}'
    publicNetworkAccess: 'Enabled'
  }
}

// 6. AZURE OPENAI
resource openAIService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: '${resourcePrefix}-openai-${uniqueSuffix}'
  location: 'eastus'  // OpenAI is only available in specific regions
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: '${resourcePrefix}-openai-${uniqueSuffix}'
    publicNetworkAccess: 'Enabled'
  }
}

// OpenAI GPT-4o Deployment
resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAIService
  name: 'gpt-4o-deployment'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0613'
    }
    raiPolicyName: 'Microsoft.Default'
  }
  sku: {
    name: 'Standard'
    capacity: 1
  }
}

// 7. APP SERVICE PLAN
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${resourcePrefix}-asp-${uniqueSuffix}'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
  properties: {
    reserved: false
  }
}

// 8. APP SERVICE (Backend)
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: '${resourcePrefix}-backend-${uniqueSuffix}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      nodeVersion: '18-lts'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'NODE_ENV'
          value: 'production'
        }
        {
          name: 'ADMIN_USERNAME'
          value: adminUsername
        }
        {
          name: 'ADMIN_PASSWORD'
          value: adminPassword
        }
        {
          name: 'COSMOS_DB_CONNECTION_STRING'
          value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
        }
        {
          name: 'AZURE_OPENAI_ENDPOINT'
          value: openAIService.properties.endpoint
        }
        {
          name: 'AZURE_OPENAI_API_KEY'
          value: openAIService.listKeys().key1
        }
        {
          name: 'AZURE_OPENAI_DEPLOYMENT_NAME'
          value: 'gpt-4o-deployment'
        }
        {
          name: 'KEY_VAULT_URL'
          value: keyVault.properties.vaultUri
        }
        {
          name: 'AZURE_STORAGE_CONNECTION_STRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'AZURE_SEARCH_ENDPOINT'
          value: 'https://${searchService.name}.search.windows.net'
        }
        {
          name: 'AZURE_SEARCH_API_KEY'
          value: searchService.listAdminKeys().primaryKey
        }
        {
          name: 'AZURE_SPEECH_KEY'
          value: cognitiveServices.listKeys().key1
        }
        {
          name: 'AZURE_SPEECH_REGION'
          value: location
        }
        {
          name: 'INSTAGRAM_APP_ID'
          value: instagramAppId
        }
        {
          name: 'INSTAGRAM_APP_SECRET'
          value: instagramAppSecret
        }
        {
          name: 'INSTAGRAM_WEBHOOK_VERIFY_TOKEN'
          value: webhookVerifyToken
        }
        {
          name: 'JWT_SECRET'
          value: uniqueString(resourceGroup().id, 'jwt-secret')
        }
        {
          name: 'JWT_EXPIRES_IN'
          value: '7d'
        }
        {
          name: 'ADMIN_JWT_EXPIRES_IN'
          value: '30d'
        }
      ]
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// 9. STATIC WEB APP (Merchant)
resource staticWebAppMerchant 'Microsoft.Web/staticSites@2023-01-01' = {
  name: '${resourcePrefix}-merchant-${uniqueSuffix}'
  location: 'East US 2'  // Static Web Apps have limited regions
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    repositoryUrl: 'https://github.com/Samer-Is/INSTAAGENT'
    branch: 'main'
    buildProperties: {
      appLocation: '/frontend-merchant'
      outputLocation: 'dist'
    }
  }
}

// 10. STATIC WEB APP (Admin)
resource staticWebAppAdmin 'Microsoft.Web/staticSites@2023-01-01' = {
  name: '${resourcePrefix}-admin-${uniqueSuffix}'
  location: 'East US 2'  // Static Web Apps have limited regions
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    repositoryUrl: 'https://github.com/Samer-Is/INSTAAGENT'
    branch: 'main'
    buildProperties: {
      appLocation: '/frontend-admin'
      outputLocation: 'dist'
    }
  }
}

// RBAC Assignments for App Service Managed Identity
resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, appService.id, 'Key Vault Secrets User')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource cosmosRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cosmosAccount.id, appService.id, 'Cosmos DB Built-in Data Contributor')
  scope: cosmosAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00000000-0000-0000-0000-000000000002') // Cosmos DB Built-in Data Contributor
    principalId: appService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output resourceGroupName string = resourceGroup().name
output cosmosAccountName string = cosmosAccount.name
output keyVaultName string = keyVault.name
output storageAccountName string = storageAccount.name
output searchServiceName string = searchService.name
output cognitiveServicesName string = cognitiveServices.name
output openAIServiceName string = openAIService.name
output appServiceName string = appService.name
output staticWebAppMerchantName string = staticWebAppMerchant.name
output staticWebAppAdminName string = staticWebAppAdmin.name
output backendUrl string = 'https://${appService.properties.defaultHostName}'
output merchantUrl string = 'https://${staticWebAppMerchant.properties.defaultHostname}'
output adminUrl string = 'https://${staticWebAppAdmin.properties.defaultHostname}' 