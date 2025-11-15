#!/bin/bash

# Script to deploy WordPress and MySQL to k3s cluster

echo "Creating namespace wedevs-namespace..."
kubectl apply -f namespace.yaml

echo "Deploying MySQL..."
kubectl apply -f database/mysql-deployment.yaml

echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n wedevs-namespace --timeout=120s

echo "Deploying WordPress..."
kubectl apply -f wordpress/wordpress-deployment.yaml

echo "Waiting for WordPress to be ready..."
kubectl wait --for=condition=ready pod -l app=wordpress -n wedevs-namespace --timeout=120s

echo "Deployment complete!"
echo ""
echo "To access WordPress via port forwarding, run:"
echo "  kubectl port-forward service/wordpress 8080:80 -n wedevs-namespace"
echo ""
echo "Then open http://localhost:8080 in your browser"

