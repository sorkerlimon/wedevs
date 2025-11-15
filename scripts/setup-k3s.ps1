# PowerShell script to set up k3s cluster (Windows)

# Note: k3s runs natively on Linux. For Windows, use WSL2 or k3d (k3s in Docker)

Write-Host "=== Setting up k3s for Windows ===" -ForegroundColor Cyan

# Check if WSL2 is available
$wslAvailable = Get-Command wsl -ErrorAction SilentlyContinue
$dockerAvailable = Get-Command docker -ErrorAction SilentlyContinue

if ($wslAvailable) {
    Write-Host "WSL2 detected. Installing k3s in WSL2..." -ForegroundColor Yellow
    Write-Host "Run the following commands in WSL2:" -ForegroundColor Yellow
    Write-Host "  curl -sfL https://get.k3s.io | sh -" -ForegroundColor Green
    Write-Host "  sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config" -ForegroundColor Green
    Write-Host "  sudo chown `$USER ~/.kube/config" -ForegroundColor Green
    exit 0
}

if ($dockerAvailable) {
    Write-Host "Docker detected. Using k3d (k3s in Docker)..." -ForegroundColor Yellow
    
    # Check if k3d is installed
    $k3dInstalled = Get-Command k3d -ErrorAction SilentlyContinue
    
    if (-not $k3dInstalled) {
        Write-Host "Installing k3d..." -ForegroundColor Yellow
        # For Windows, download from GitHub releases
        $k3dUrl = "https://github.com/k3d-io/k3d/releases/latest/download/k3d-windows-amd64.exe"
        $k3dPath = "$env:USERPROFILE\.local\bin\k3d.exe"
        New-Item -ItemType Directory -Force -Path (Split-Path $k3dPath) | Out-Null
        Invoke-WebRequest -Uri $k3dUrl -OutFile $k3dPath
        $env:Path += ";$env:USERPROFILE\.local\bin"
        [Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::User)
        Write-Host "✓ k3d installed" -ForegroundColor Green
    }
    
    Write-Host "Creating k3d cluster..." -ForegroundColor Yellow
    k3d cluster create local-dev --port "80:80@loadbalancer" --port "443:443@loadbalancer"
    k3d kubeconfig merge local-dev --kubeconfig-merge-default
    
    Write-Host "✓ k3d cluster created" -ForegroundColor Green
    kubectl get nodes
    
    Write-Host "=== k3d cluster is ready ===" -ForegroundColor Green
    exit 0
}

Write-Host "ERROR: Neither WSL2 nor Docker found!" -ForegroundColor Red
Write-Host "Please install either:" -ForegroundColor Yellow
Write-Host "1. WSL2: https://docs.microsoft.com/en-us/windows/wsl/install" -ForegroundColor Yellow
Write-Host "2. Docker Desktop: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
exit 1

