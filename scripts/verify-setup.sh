#!/bin/bash

# Script to verify the setup is correct before bootstrapping FluxCD

set -e

echo "=== Verifying GitOps Setup ==="
echo ""

# Check if required files exist
echo "Checking required files..."
FILES=(
    "clusters/local/flux-system/gotk-sync.yaml"
    "clusters/local/kustomization.yaml"
    "infrastructure/metallb/ipaddresspool.yaml"
    "infrastructure/ingress-nginx/helmrelease.yaml"
    "workloads/mysql/secret.enc.yaml"
    "workloads/wordpress/secret.enc.yaml"
)

MISSING=0
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ $file (MISSING)"
        MISSING=1
    fi
done

if [ $MISSING -eq 1 ]; then
    echo ""
    echo "ERROR: Some required files are missing!"
    exit 1
fi

echo ""
echo "Checking SOPS configuration..."

# Check if .sops.yaml exists and has public key
if grep -q "PUBLIC_KEY_HERE" .sops.yaml; then
    echo "⚠ .sops.yaml still contains PUBLIC_KEY_HERE placeholder"
    echo "  Update with your age public key!"
else
    echo "✓ .sops.yaml configured"
fi

if grep -q "PUBLIC_KEY_HERE" clusters/local/flux-system/.sops.yaml; then
    echo "⚠ clusters/local/flux-system/.sops.yaml still contains PUBLIC_KEY_HERE placeholder"
    echo "  Update with your age public key!"
else
    echo "✓ clusters/local/flux-system/.sops.yaml configured"
fi

echo ""
echo "Checking GitHub repository configuration..."

# Check if gotk-sync.yaml has placeholders
if grep -q "YOUR_USERNAME\|YOUR_REPO_NAME" clusters/local/flux-system/gotk-sync.yaml; then
    echo "⚠ gotk-sync.yaml still contains placeholders"
    echo "  Update YOUR_USERNAME and YOUR_REPO_NAME!"
else
    echo "✓ gotk-sync.yaml configured"
fi

echo ""
echo "Checking encrypted secrets..."

# Check if secrets are encrypted (SOPS encrypted files have specific markers)
if grep -q "ENC\[" workloads/mysql/secret.enc.yaml 2>/dev/null; then
    echo "✓ MySQL secret is encrypted"
elif grep -q "sops:" workloads/mysql/secret.enc.yaml 2>/dev/null; then
    echo "✓ MySQL secret is encrypted (SOPS v3 format)"
else
    echo "⚠ MySQL secret may not be encrypted"
    echo "  Run: sops -e -i workloads/mysql/secret.enc.yaml"
fi

if grep -q "ENC\[" workloads/wordpress/secret.enc.yaml 2>/dev/null; then
    echo "✓ WordPress secret is encrypted"
elif grep -q "sops:" workloads/wordpress/secret.enc.yaml 2>/dev/null; then
    echo "✓ WordPress secret is encrypted (SOPS v3 format)"
else
    echo "⚠ WordPress secret may not be encrypted"
    echo "  Run: sops -e -i workloads/wordpress/secret.enc.yaml"
fi

echo ""
echo "Checking git status..."

if [ -d ".git" ]; then
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠ You have uncommitted changes"
        echo "  Commit and push before bootstrapping FluxCD!"
    else
        echo "✓ All changes committed"
    fi
else
    echo "⚠ Not a git repository"
    echo "  Initialize git and push to GitHub before bootstrapping!"
fi

echo ""
echo "=== Verification Complete ==="
echo ""
echo "Next steps:"
echo "1. Fix any warnings above"
echo "2. Push all changes to GitHub"
echo "3. Create SOPS secret in Kubernetes:"
echo "   kubectl create secret generic sops-age \\"
echo "     --from-file=age.agekey=age-key.txt \\"
echo "     --namespace=flux-system"
echo "4. Bootstrap FluxCD:"
echo "   flux bootstrap github \\"
echo "     --owner=YOUR_USERNAME \\"
echo "     --repository=YOUR_REPO_NAME \\"
echo "     --branch=main \\"
echo "     --path=./clusters/local \\"
echo "     --personal"

