# PowerShell script to port forward WordPress service

Write-Host "Starting port forwarding for WordPress..." -ForegroundColor Green
Write-Host "Access WordPress at: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop port forwarding" -ForegroundColor Yellow
Write-Host ""

kubectl port-forward service/wordpress 8080:80 -n wedevs-namespace

