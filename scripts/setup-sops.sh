#!/bin/bash

# Script to set up SOPS with age

set -e

echo "=== Setting up SOPS with age ==="

# Check if SOPS is installed
if ! command -v sops &> /dev/null; then
    echo "SOPS not found. Installing..."
    # For Windows (using chocolatey or manual download)
    # For Linux/Mac, you can use: brew install sops or apt-get install sops
    echo "Please install SOPS manually: https://github.com/getsops/sops/releases"
    exit 1
fi

# Check if age is installed
if ! command -v age &> /dev/null; then
    echo "age not found. Installing..."
    echo "Please install age manually: https://github.com/FiloSottile/age"
    exit 1
fi

# Generate age key pair
echo "=== Generating age key pair ==="
age-keygen -o age-key.txt

PRIVATE_KEY=$(cat age-key.txt | grep -oP 'AGE-SECRET-KEY-\K[^"]*')
PUBLIC_KEY=$(age-keygen -y age-key.txt)

echo "=== Age key pair generated ==="
echo "PRIVATE_KEY saved to age-key.txt (KEEP THIS SECRET!)"
echo ""
echo "PUBLIC_KEY: $PUBLIC_KEY"
echo ""
echo "=== Update the following files with your PUBLIC_KEY: ==="
echo "1. .sops.yaml - replace PUBLIC_KEY_HERE"
echo "2. clusters/local/flux-system/.sops.yaml - replace PUBLIC_KEY_HERE"
echo "3. For FluxCD, export the private key as an environment variable or create a secret"
echo ""
echo "To use with FluxCD, create a secret:"
echo "kubectl create secret generic sops-age \\"
echo "  --from-file=age.agekey=<(cat age-key.txt) \\"
echo "  --namespace=flux-system"

