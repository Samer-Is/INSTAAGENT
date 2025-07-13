// Minimal test template for Instagram AI Agent Platform
param location string = resourceGroup().location
param projectName string = 'insta-ai-agent'
param environment string = 'dev'

var resourcePrefix = '${projectName}-${environment}'
var uniqueSuffix = uniqueString(resourceGroup().id)

// 1. STORAGE ACCOUNT (minimal)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${take(replace(resourcePrefix, '-', ''), 10)}${take(uniqueSuffix, 13)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

// 2. APP SERVICE PLAN (Free tier)
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

// 3. APP SERVICE (Basic)
resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: '${resourcePrefix}-backend-${uniqueSuffix}'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      nodeVersion: '18-lts'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'NODE_ENV'
          value: 'production'
        }
        {
          name: 'TEST_DEPLOYMENT'
          value: 'true'
        }
      ]
    }
  }
}

// Outputs
output storageAccountName string = storageAccount.name
output appServiceName string = appService.name
output appServiceUrl string = 'https://${appService.properties.defaultHostName}'
output resourceGroupName string = resourceGroup().name 