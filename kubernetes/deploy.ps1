# PowerShell script to deploy WordPress and MySQL to k3s cluster

Write-Host "Creating namespace wedevs-namespace..." -ForegroundColor Green
kubectl apply -f namespace.yaml

Write-Host "Deploying MySQL..." -ForegroundColor Green
kubectl apply -f database/mysql-deployment.yaml

Write-Host "Waiting for MySQL to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=mysql -n wedevs-namespace --timeout=120s

if ($LASTEXITCODE -eq 0) {
    Write-Host "MySQL is ready!" -ForegroundColor Green
} else {
    Write-Host "MySQL deployment may still be in progress. Check with: kubectl get pods -n wedevs-namespace" -ForegroundColor Yellow
}

Write-Host "`nDeploying WordPress..." -ForegroundColor Green
kubectl apply -f wordpress/wordpress-deployment.yaml

Write-Host "Waiting for WordPress to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=wordpress -n wedevs-namespace --timeout=120s

if ($LASTEXITCODE -eq 0) {
    Write-Host "WordPress is ready!" -ForegroundColor Green
} else {
    Write-Host "WordPress deployment may still be in progress. Check with: kubectl get pods -n wedevs-namespace" -ForegroundColor Yellow
}

Write-Host "`nDeployment complete!" -ForegroundColor Green
Write-Host "`nTo access WordPress via port forwarding, run:" -ForegroundColor Cyan
Write-Host "  kubectl port-forward service/wordpress 8080:80 -n wedevs-namespace" -ForegroundColor White
Write-Host "`nThen open http://localhost:8080 in your browser" -ForegroundColor Cyan

