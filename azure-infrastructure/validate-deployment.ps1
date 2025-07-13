# Instagram AI Agent SaaS Platform - Deployment Validation Script
# This script validates that all Azure resources were created successfully

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-insta-ai-agent-dev",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "deployment-outputs.json"
)

# Color output functions
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

Write-Info "Validating Instagram AI Agent Platform deployment..."
Write-Info "Resource Group: $ResourceGroupName"

try {
    # Check if resource group exists
    Write-Info "Checking resource group..."
    $rg = az group show --name $ResourceGroupName --output json 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Resource group '$ResourceGroupName' not found"
        exit 1
    }
    Write-Success "Resource group found"

    # Get all resources in the resource group
    Write-Info "Fetching resources in resource group..."
    $resources = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
    
    if ($resources.Count -eq 0) {
        Write-Error "No resources found in resource group"
        exit 1
    }

    Write-Success "Found $($resources.Count) resources"

    # Expected resource types
    $expectedResources = @(
        "Microsoft.DocumentDB/databaseAccounts",        # Cosmos DB
        "Microsoft.KeyVault/vaults",                    # Key Vault
        "Microsoft.Storage/storageAccounts",            # Storage Account
        "Microsoft.Search/searchServices",              # Cognitive Search
        "Microsoft.CognitiveServices/accounts",         # Cognitive Services (Speech + OpenAI)
        "Microsoft.Web/serverfarms",                    # App Service Plan
        "Microsoft.Web/sites",                          # App Service
        "Microsoft.Web/staticSites"                     # Static Web Apps
    )

    Write-Info "Validating required resource types..."
    $foundResources = @{}
    
    foreach ($resource in $resources) {
        $type = $resource.type
        if ($foundResources.ContainsKey($type)) {
            $foundResources[$type]++
        } else {
            $foundResources[$type] = 1
        }
    }

    $allResourcesFound = $true
    foreach ($expectedType in $expectedResources) {
        if ($foundResources.ContainsKey($expectedType)) {
            $count = $foundResources[$expectedType]
            if ($expectedType -eq "Microsoft.CognitiveServices/accounts") {
                # Should have 2: Speech + OpenAI
                if ($count -ge 2) {
                    Write-Success "✓ $expectedType ($count found)"
                } else {
                    Write-Warning "⚠ $expectedType (expected 2, found $count)"
                }
            } elseif ($expectedType -eq "Microsoft.Web/staticSites") {
                # Should have 2: Merchant + Admin
                if ($count -ge 2) {
                    Write-Success "✓ $expectedType ($count found)"
                } else {
                    Write-Warning "⚠ $expectedType (expected 2, found $count)"
                }
            } else {
                Write-Success "✓ $expectedType ($count found)"
            }
        } else {
            Write-Error "✗ $expectedType (not found)"
            $allResourcesFound = $false
        }
    }

    # Check deployment outputs file
    if (Test-Path $OutputFile) {
        Write-Info "Checking deployment outputs file..."
        $outputs = Get-Content $OutputFile | ConvertFrom-Json
        
        $requiredOutputs = @(
            "backendUrl",
            "merchantUrl", 
            "adminUrl",
            "cosmosAccountName",
            "keyVaultName",
            "storageAccountName"
        )

        $allOutputsFound = $true
                 foreach ($output in $requiredOutputs) {
             if ($outputs.PSObject.Properties.Name -contains $output) {
                 $value = $outputs.$output.value
                 Write-Success "✓ $output = $value"
             } else {
                 Write-Error "✗ $output (missing from outputs)"
                 $allOutputsFound = $false
             }
         }

        if ($allOutputsFound) {
            Write-Success "All required outputs found"
        }
    } else {
        Write-Warning "Deployment outputs file not found: $OutputFile"
    }

    # Test connectivity to key endpoints
    Write-Info "Testing endpoint connectivity..."
    
    if (Test-Path $OutputFile) {
        $outputs = Get-Content $OutputFile | ConvertFrom-Json
        
        if ($outputs.backendUrl) {
            $backendUrl = $outputs.backendUrl.value
            Write-Info "Testing backend URL: $backendUrl"
            
            try {
                $response = Invoke-WebRequest -Uri $backendUrl -Method GET -TimeoutSec 10 -ErrorAction Stop
                Write-Success "Backend endpoint is accessible (Status: $($response.StatusCode))"
            } catch {
                Write-Warning "Backend endpoint test failed: $($_.Exception.Message)"
            }
        }
    }

    # Summary
    Write-Host ""
    if ($allResourcesFound) {
        Write-Success "🎉 Deployment validation completed successfully!"
        Write-Info "All required Azure resources are present and configured"
    } else {
        Write-Warning "⚠️  Deployment validation completed with warnings"
        Write-Info "Some resources may be missing or still deploying"
    }

    Write-Host ""
    Write-Info "📋 Resource Summary:"
    foreach ($type in $foundResources.Keys) {
        $count = $foundResources[$type]
        Write-Host "   $type: $count" -ForegroundColor White
    }

} catch {
    Write-Error "Validation failed: $($_.Exception.Message)"
    exit 1
} 