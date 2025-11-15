#!/bin/bash

# Script to set up k3s cluster with FluxCD

set -e

echo "=== Setting up k3s Cluster ==="

# Check if k3s is already installed
if command -v k3s &> /dev/null; then
    echo "k3s is already installed"
    k3s --version
else
    echo "Installing k3s..."
    curl -sfL https://get.k3s.io | sh -
    echo "✓ k3s installed successfully"
fi

# Configure kubectl
if [ ! -f ~/.kube/config ]; then
    echo "Configuring kubectl..."
    mkdir -p ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $USER ~/.kube/config
    echo "✓ kubectl configured"
else
    echo "kubectl already configured"
fi

# Verify cluster is running
echo "Verifying cluster..."
kubectl cluster-info
kubectl get nodes

echo "=== k3s cluster is ready ==="
echo ""
echo "Next steps:"
echo "1. Install FluxCD CLI: curl -s https://fluxcd.io/install.sh | bash"
echo "2. Generate age keys: ./scripts/setup-sops.sh"
echo "3. Configure secrets and bootstrap FluxCD"

