#!/bin/bash

# Instagram AI Agent SaaS Platform - Azure Infrastructure Deployment Script
# This script creates all Azure resources from scratch

set -e

# Color output functions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

function write_success() { echo -e "${GREEN}✅ $1${NC}"; }
function write_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
function write_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
function write_error() { echo -e "${RED}❌ $1${NC}"; }

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --subscription-id)
            SUBSCRIPTION_ID="$2"
            shift 2
            ;;
        --admin-password)
            ADMIN_PASSWORD="$2"
            shift 2
            ;;
        --instagram-app-id)
            INSTAGRAM_APP_ID="$2"
            shift 2
            ;;
        --instagram-app-secret)
            INSTAGRAM_APP_SECRET="$2"
            shift 2
            ;;
        --webhook-verify-token)
            WEBHOOK_VERIFY_TOKEN="$2"
            shift 2
            ;;
        --resource-group)
            RESOURCE_GROUP_NAME="$2"
            shift 2
            ;;
        --location)
            LOCATION="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --subscription-id         Azure subscription ID (required)"
            echo "  --admin-password          Admin password for the platform (required)"
            echo "  --instagram-app-id        Instagram App ID (required)"
            echo "  --instagram-app-secret    Instagram App Secret (required)"
            echo "  --webhook-verify-token    Webhook verify token (required)"
            echo "  --resource-group          Resource group name (default: rg-insta-ai-agent-dev)"
            echo "  --location                Azure location (default: East US)"
            echo "  --help                    Show this help message"
            exit 0
            ;;
        *)
            write_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Set defaults
RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME:-"rg-insta-ai-agent-dev"}
LOCATION=${LOCATION:-"East US"}

# Validate required parameters
if [[ -z "$SUBSCRIPTION_ID" ]]; then
    write_error "Subscription ID is required. Use --subscription-id"
    exit 1
fi

if [[ -z "$ADMIN_PASSWORD" ]]; then
    write_error "Admin password is required. Use --admin-password"
    exit 1
fi

if [[ -z "$INSTAGRAM_APP_ID" ]]; then
    write_error "Instagram App ID is required. Use --instagram-app-id"
    exit 1
fi

if [[ -z "$INSTAGRAM_APP_SECRET" ]]; then
    write_error "Instagram App Secret is required. Use --instagram-app-secret"
    exit 1
fi

if [[ -z "$WEBHOOK_VERIFY_TOKEN" ]]; then
    write_error "Webhook verify token is required. Use --webhook-verify-token"
    exit 1
fi

write_info "Starting Instagram AI Agent Platform deployment..."
write_info "Subscription: $SUBSCRIPTION_ID"
write_info "Resource Group: $RESOURCE_GROUP_NAME"
write_info "Location: $LOCATION"

# Check if Azure CLI is installed
write_info "Checking Azure CLI installation..."
if ! command -v az &> /dev/null; then
    write_error "Azure CLI is not installed. Please install Azure CLI first."
    write_info "Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
write_success "Azure CLI version $AZ_VERSION found"

# Login to Azure
write_info "Logging in to Azure..."
if ! az login --output none > /dev/null 2>&1; then
    write_error "Failed to login to Azure. Please run 'az login' manually."
    exit 1
fi
write_success "Successfully logged in to Azure"

# Set subscription
write_info "Setting subscription to $SUBSCRIPTION_ID..."
if ! az account set --subscription "$SUBSCRIPTION_ID"; then
    write_error "Failed to set subscription. Please check the subscription ID."
    exit 1
fi
write_success "Subscription set successfully"

# Create resource group
write_info "Creating resource group $RESOURCE_GROUP_NAME..."
if ! az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION" --output none; then
    write_error "Failed to create resource group"
    exit 1
fi
write_success "Resource group created successfully"

# Deploy Bicep template
write_info "Deploying Azure infrastructure... This may take 10-15 minutes..."
write_warning "Please be patient, this will create all Azure resources from scratch"

DEPLOYMENT_RESULT=$(az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "main.bicep" \
    --parameters "adminPassword=$ADMIN_PASSWORD" \
    --parameters "instagramAppId=$INSTAGRAM_APP_ID" \
    --parameters "instagramAppSecret=$INSTAGRAM_APP_SECRET" \
    --parameters "webhookVerifyToken=$WEBHOOK_VERIFY_TOKEN" \
    --output json)

if [[ $? -ne 0 ]]; then
    write_error "Deployment failed. Check the error messages above."
    exit 1
fi

# Parse deployment outputs
BACKEND_URL=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.backendUrl.value')
MERCHANT_URL=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.merchantUrl.value')
ADMIN_URL=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.adminUrl.value')
COSMOS_NAME=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.cosmosAccountName.value')
KEYVAULT_NAME=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.keyVaultName.value')
STORAGE_NAME=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.storageAccountName.value')
SEARCH_NAME=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.searchServiceName.value')
COGNITIVE_NAME=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.cognitiveServicesName.value')
OPENAI_NAME=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.openAIServiceName.value')
APPSERVICE_NAME=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.appServiceName.value')
SWA_MERCHANT_NAME=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.staticWebAppMerchantName.value')
SWA_ADMIN_NAME=$(echo "$DEPLOYMENT_RESULT" | jq -r '.properties.outputs.staticWebAppAdminName.value')

write_success "🎉 Deployment completed successfully!"
write_info "📋 Deployment Summary:"
echo ""
echo -e "${MAGENTA}🔗 Resource URLs:${NC}"
echo -e "   ${WHITE}Backend API: $BACKEND_URL${NC}"
echo -e "   ${WHITE}Merchant Dashboard: $MERCHANT_URL${NC}"
echo -e "   ${WHITE}Admin Dashboard: $ADMIN_URL${NC}"
echo ""
echo -e "${MAGENTA}📦 Azure Resources Created:${NC}"
echo -e "   ${WHITE}Resource Group: $RESOURCE_GROUP_NAME${NC}"
echo -e "   ${WHITE}Cosmos DB: $COSMOS_NAME${NC}"
echo -e "   ${WHITE}Key Vault: $KEYVAULT_NAME${NC}"
echo -e "   ${WHITE}Storage Account: $STORAGE_NAME${NC}"
echo -e "   ${WHITE}Search Service: $SEARCH_NAME${NC}"
echo -e "   ${WHITE}Cognitive Services: $COGNITIVE_NAME${NC}"
echo -e "   ${WHITE}OpenAI Service: $OPENAI_NAME${NC}"
echo -e "   ${WHITE}App Service: $APPSERVICE_NAME${NC}"
echo -e "   ${WHITE}Static Web App (Merchant): $SWA_MERCHANT_NAME${NC}"
echo -e "   ${WHITE}Static Web App (Admin): $SWA_ADMIN_NAME${NC}"
echo ""

# Save outputs to file
OUTPUTS_FILE="deployment-outputs.json"
echo "$DEPLOYMENT_RESULT" | jq '.properties.outputs' > "$OUTPUTS_FILE"
write_success "Deployment outputs saved to $OUTPUTS_FILE"

write_info "🔄 Next Steps:"
echo -e "${YELLOW}1. Configure GitHub repository secrets for CI/CD${NC}"
echo -e "${YELLOW}2. Update environment variables in frontend applications${NC}"
echo -e "${YELLOW}3. Test the deployment by running the applications${NC}"
echo -e "${YELLOW}4. Configure Instagram webhook URL in Meta Developer Console${NC}" 