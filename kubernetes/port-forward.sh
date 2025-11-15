#!/bin/bash

# Script to port forward WordPress service

echo "Starting port forwarding for WordPress..."
echo "Access WordPress at: http://localhost:8080"
echo "Press Ctrl+C to stop port forwarding"
echo ""

kubectl port-forward service/wordpress 8080:80 -n wedevs-namespace

