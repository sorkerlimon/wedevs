# PowerShell script to bootstrap FluxCD

# Check if GITHUB_TOKEN is set
if (-not $env:GITHUB_TOKEN) {
    Write-Host "ERROR: GITHUB_TOKEN environment variable is not set!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please follow these steps:" -ForegroundColor Yellow
    Write-Host "1. Create a GitHub Personal Access Token (PAT) at:" -ForegroundColor Cyan
    Write-Host "   https://github.com/settings/tokens" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Select the 'repo' scope (full control of private repositories)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. Generate the token and copy it" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "4. Set it as an environment variable:" -ForegroundColor Cyan
    Write-Host "   `$env:GITHUB_TOKEN = 'your-token-here'" -ForegroundColor White
    Write-Host ""
    Write-Host "5. Or run this script after setting the variable:" -ForegroundColor Cyan
    Write-Host "   `$env:GITHUB_TOKEN = 'your-token'; .\scripts\bootstrap-flux.ps1" -ForegroundColor White
    exit 1
}

$fluxPath = "$env:USERPROFILE\.local\bin\flux.exe"

if (-not (Test-Path $fluxPath)) {
    Write-Host "ERROR: Flux CLI not found at $fluxPath" -ForegroundColor Red
    Write-Host "Please install Flux CLI first" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Bootstrapping FluxCD ===" -ForegroundColor Cyan
Write-Host "Repository: sorkerlimon/wedevs" -ForegroundColor Green
Write-Host "Branch: main" -ForegroundColor Green
Write-Host "Path: ./clusters/local" -ForegroundColor Green
Write-Host ""

& $fluxPath bootstrap github `
    --owner=sorkerlimon `
    --repository=wedevs `
    --branch=main `
    --path=./clusters/local `
    --personal

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== FluxCD Bootstrapped Successfully! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Checking FluxCD status..." -ForegroundColor Cyan
    & $fluxPath get all --all-namespaces
} else {
    Write-Host ""
    Write-Host "ERROR: Bootstrap failed. Please check the error messages above." -ForegroundColor Red
    exit 1
}

