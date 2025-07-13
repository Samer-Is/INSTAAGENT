# Simple Azure deployment test
$resourceGroup = "rg-insta-ai-agent-dev"

Write-Host "Testing Azure Infrastructure..." -ForegroundColor Cyan

# Check resource group
Write-Host "Checking resource group..." -ForegroundColor Yellow
$rg = az group show --name $resourceGroup 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Resource group exists" -ForegroundColor Green
} else {
    Write-Host "ERROR: Resource group not found" -ForegroundColor Red
    exit 1
}

# List resources
Write-Host "Listing resources..." -ForegroundColor Yellow
$resources = az resource list --resource-group $resourceGroup --output json | ConvertFrom-Json
Write-Host "SUCCESS: Found $($resources.Count) resources" -ForegroundColor Green

# Show resources
foreach ($resource in $resources) {
    Write-Host "  - $($resource.name) ($($resource.type))" -ForegroundColor White
}

Write-Host "PHASE 0 INFRASTRUCTURE TEST: PASSED" -ForegroundColor Green 