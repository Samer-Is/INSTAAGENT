# Instagram AI Agent SaaS Platform - Azure Infrastructure Deployment Script
# This script creates all Azure resources from scratch

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$AdminPassword,
    
    [Parameter(Mandatory=$true)]
    [string]$InstagramAppId,
    
    [Parameter(Mandatory=$true)]
    [string]$InstagramAppSecret,
    
    [Parameter(Mandatory=$true)]
    [string]$WebhookVerifyToken,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-insta-ai-agent-dev",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US"
)

# Color output functions
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

Write-Info "Starting Instagram AI Agent Platform deployment..."
Write-Info "Subscription: $SubscriptionId"
Write-Info "Resource Group: $ResourceGroupName"
Write-Info "Location: $Location"

try {
    # Check if Azure CLI is installed
    Write-Info "Checking Azure CLI installation..."
    $azVersion = az version --output tsv --query '"azure-cli"' 2>$null
    if (-not $azVersion) {
        Write-Error "Azure CLI is not installed. Please install Azure CLI first."
        Write-Info "Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    }
    Write-Success "Azure CLI version $azVersion found"

    # Login to Azure
    Write-Info "Logging in to Azure..."
    $loginResult = az login --output none 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to login to Azure. Please run 'az login' manually."
        exit 1
    }
    Write-Success "Successfully logged in to Azure"

    # Set subscription
    Write-Info "Setting subscription to $SubscriptionId..."
    az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to set subscription. Please check the subscription ID."
        exit 1
    }
    Write-Success "Subscription set successfully"

    # Create resource group
    Write-Info "Creating resource group $ResourceGroupName..."
    az group create --name $ResourceGroupName --location $Location --output none
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create resource group"
        exit 1
    }
    Write-Success "Resource group created successfully"

    # Deploy Bicep template
    Write-Info "Deploying Azure infrastructure... This may take 10-15 minutes..."
    Write-Warning "Please be patient, this will create all Azure resources from scratch"
    
    $deploymentResult = az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "main.bicep" `
        --parameters "adminPassword=$AdminPassword" `
        --parameters "instagramAppId=$InstagramAppId" `
        --parameters "instagramAppSecret=$InstagramAppSecret" `
        --parameters "webhookVerifyToken=$WebhookVerifyToken" `
        --output json

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Deployment failed. Check the error messages above."
        exit 1
    }

    # Parse deployment outputs
    $deployment = $deploymentResult | ConvertFrom-Json
    $outputs = $deployment.properties.outputs

    Write-Success "🎉 Deployment completed successfully!"
    Write-Info "📋 Deployment Summary:"
    Write-Host ""
    Write-Host "🔗 Resource URLs:" -ForegroundColor Magenta
    Write-Host "   Backend API: $($outputs.backendUrl.value)" -ForegroundColor White
    Write-Host "   Merchant Dashboard: $($outputs.merchantUrl.value)" -ForegroundColor White
    Write-Host "   Admin Dashboard: $($outputs.adminUrl.value)" -ForegroundColor White
    Write-Host ""
    Write-Host "📦 Azure Resources Created:" -ForegroundColor Magenta
    Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
    Write-Host "   Cosmos DB: $($outputs.cosmosAccountName.value)" -ForegroundColor White
    Write-Host "   Key Vault: $($outputs.keyVaultName.value)" -ForegroundColor White
    Write-Host "   Storage Account: $($outputs.storageAccountName.value)" -ForegroundColor White
    Write-Host "   Search Service: $($outputs.searchServiceName.value)" -ForegroundColor White
    Write-Host "   Cognitive Services: $($outputs.cognitiveServicesName.value)" -ForegroundColor White
    Write-Host "   OpenAI Service: $($outputs.openAIServiceName.value)" -ForegroundColor White
    Write-Host "   App Service: $($outputs.appServiceName.value)" -ForegroundColor White
    Write-Host "   Static Web App (Merchant): $($outputs.staticWebAppMerchantName.value)" -ForegroundColor White
    Write-Host "   Static Web App (Admin): $($outputs.staticWebAppAdminName.value)" -ForegroundColor White
    Write-Host ""
    
    # Save outputs to file
    $outputsFile = "deployment-outputs.json"
    $outputs | ConvertTo-Json -Depth 3 | Out-File $outputsFile
    Write-Success "Deployment outputs saved to $outputsFile"
    
    Write-Info "🔄 Next Steps:"
    Write-Host "1. Configure GitHub repository secrets for CI/CD" -ForegroundColor Yellow
    Write-Host "2. Update environment variables in frontend applications" -ForegroundColor Yellow
    Write-Host "3. Test the deployment by running the applications" -ForegroundColor Yellow
    Write-Host "4. Configure Instagram webhook URL in Meta Developer Console" -ForegroundColor Yellow
    
} catch {
    Write-Error "An error occurred during deployment: $($_.Exception.Message)"
    exit 1
} 