# PowerShell script to setup k3s cluster named 'webdevs'
# Note: k3s is primarily for Linux. On Windows, you may need WSL2 or a Linux VM

Write-Host "Setting up k3s cluster 'webdevs'..." -ForegroundColor Green

# Check if running in WSL
if ($IsLinux -or (Get-Command wsl -ErrorAction SilentlyContinue)) {
    Write-Host "Detected Linux/WSL environment. Installing k3s..." -ForegroundColor Yellow
    
    # If in WSL, run the bash script
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        Write-Host "Running k3s installation via WSL..." -ForegroundColor Yellow
        wsl bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--cluster-init' sh -"
        Write-Host "k3s installed. Configure kubectl with:" -ForegroundColor Green
        Write-Host "  wsl sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config" -ForegroundColor Cyan
    }
} else {
    Write-Host "k3s requires Linux. Please use one of the following options:" -ForegroundColor Red
    Write-Host "1. Install WSL2 and run k3s inside WSL" -ForegroundColor Yellow
    Write-Host "2. Use a Linux VM" -ForegroundColor Yellow
    Write-Host "3. Use Docker Desktop with Kubernetes enabled" -ForegroundColor Yellow
    Write-Host "4. Use minikube or kind for local Kubernetes" -ForegroundColor Yellow
}

Write-Host "`nFor manual installation in WSL/Linux:" -ForegroundColor Cyan
Write-Host "  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--cluster-init' sh -" -ForegroundColor White
Write-Host "  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" -ForegroundColor White

