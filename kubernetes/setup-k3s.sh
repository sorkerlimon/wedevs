#!/bin/bash

# Script to setup k3s cluster named 'webdevs'
# This script installs k3s and sets up the cluster

echo "Installing k3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--cluster-init" sh -

echo "Waiting for k3s to be ready..."
sleep 10

# Set KUBECONFIG
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Make k3s.yaml readable
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

echo "k3s cluster 'webdevs' is being set up..."
echo "To use kubectl, run: export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
echo "Or copy the config: sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config"

# Verify cluster
echo "Verifying cluster..."
kubectl cluster-info
kubectl get nodes

echo "Setup complete! You can now deploy your applications."

