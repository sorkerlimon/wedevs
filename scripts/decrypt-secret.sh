#!/bin/bash

# Script to decrypt secrets with SOPS for editing

set -e

MYSQL_SECRET="workloads/mysql/secret.enc.yaml"
WORDPRESS_SECRET="workloads/wordpress/secret.enc.yaml"

echo "=== Decrypting secrets with SOPS ==="

# Decrypt MySQL secret
if [ -f "$MYSQL_SECRET" ]; then
    echo "Decrypting MySQL secret..."
    sops -d -i "$MYSQL_SECRET"
    echo "✓ MySQL secret decrypted: $MYSQL_SECRET"
else
    echo "⚠ MySQL secret file not found: $MYSQL_SECRET"
fi

# Decrypt WordPress secret
if [ -f "$WORDPRESS_SECRET" ]; then
    echo "Decrypting WordPress secret..."
    sops -d -i "$WORDPRESS_SECRET"
    echo "✓ WordPress secret decrypted: $WORDPRESS_SECRET"
else
    echo "⚠ WordPress secret file not found: $WORDPRESS_SECRET"
fi

echo "=== Secrets decrypted. Edit them, then run encrypt-secret.sh ==="

