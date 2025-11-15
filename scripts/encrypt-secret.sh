#!/bin/bash

# Script to encrypt secrets with SOPS

set -e

MYSQL_SECRET="workloads/mysql/secret.enc.yaml"
WORDPRESS_SECRET="workloads/wordpress/secret.enc.yaml"

echo "=== Encrypting secrets with SOPS ==="

# Encrypt MySQL secret
if [ -f "$MYSQL_SECRET" ]; then
    echo "Encrypting MySQL secret..."
    sops -e -i "$MYSQL_SECRET"
    echo "✓ MySQL secret encrypted: $MYSQL_SECRET"
else
    echo "⚠ MySQL secret file not found: $MYSQL_SECRET"
fi

# Encrypt WordPress secret
if [ -f "$WORDPRESS_SECRET" ]; then
    echo "Encrypting WordPress secret..."
    sops -e -i "$WORDPRESS_SECRET"
    echo "✓ WordPress secret encrypted: $WORDPRESS_SECRET"
else
    echo "⚠ WordPress secret file not found: $WORDPRESS_SECRET"
fi

echo "=== All secrets encrypted successfully ==="
echo ""
echo "Important: Ensure both secrets have matching database credentials!"
echo "  MySQL username/password must match WordPress DB_USER/DB_PASSWORD"

