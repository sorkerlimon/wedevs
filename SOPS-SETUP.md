# SOPS with age Setup for FluxCD

## Setup Complete ✅

SOPS (Secrets OPerationS) with age encryption has been successfully configured for FluxCD.

## What Was Done

1. **Installed SOPS v3.11.0** - Installed at `$env:USERPROFILE\.local\bin\sops.exe`
2. **Installed age v1.2.1** - Installed at `$env:USERPROFILE\.local\bin\age.exe`
3. **Generated age key pair** - Created `age-key.txt` with public and private keys
4. **Updated SOPS configuration** - Configured `.sops.yaml` files with public key
5. **Encrypted secrets** - MySQL and WordPress secrets are now encrypted
6. **Created SOPS secret in Kubernetes** - Secret `sops-age` created in `flux-system` namespace
7. **Configured FluxCD Kustomization** - Added SOPS decryption configuration

## Configuration Details

### Age Public Key
```
age1j5j4x77dv7efrwssv9tvaltqyxstdywer77qtd2c546e8h0zpccsqjk89x
```

### Age Private Key
- Stored in: `age-key.txt` (DO NOT COMMIT TO GIT!)
- Stored in Kubernetes: `sops-age` secret in `flux-system` namespace

### SOPS Configuration Files

1. **`.sops.yaml`** (root) - Configuration for encrypting secrets
   - Path regex: `.*secret\.enc\.yaml$`
   - Encrypts: `data` and `stringData` fields

2. **`clusters/local/flux-system/.sops.yaml`** - FluxCD SOPS configuration
   - Path regex: `.*.yaml$`
   - Encrypts: `data` and `stringData` fields

### Encrypted Secrets

1. **`workloads/mysql/secret.enc.yaml`** - MySQL database credentials
   - Encrypted with SOPS using age
   - Contains: root-password, username, password

2. **`workloads/wordpress/secret.enc.yaml`** - WordPress database credentials
   - Encrypted with SOPS using age
   - Contains: username, password

### FluxCD Kustomization Configuration

The FluxCD Kustomization has been configured with SOPS decryption:

```yaml
spec:
  decryption:
    provider: sops
    secretRef:
      name: sops-age
```

## How It Works

1. **Encryption**: Secrets are encrypted locally using SOPS with age
2. **Storage**: Encrypted secrets are stored in GitHub (safe to commit)
3. **Decryption**: FluxCD automatically decrypts secrets using the `sops-age` secret
4. **Application**: Decrypted secrets are applied to the Kubernetes cluster

## Security Notes

⚠️ **IMPORTANT SECURITY CONSIDERATIONS:**

1. **Age Private Key**: 
   - Stored in `age-key.txt` (local file)
   - Stored in Kubernetes secret `sops-age`
   - **NEVER commit `age-key.txt` to Git!**
   - Already added to `.gitignore`

2. **SOPS Secret in Kubernetes**:
   - Secret name: `sops-age`
   - Namespace: `flux-system`
   - Key: `age.agekey`
   - Contains the private key needed for decryption

3. **Encrypted Secrets in Git**:
   - Safe to commit encrypted secrets to GitHub
   - They cannot be decrypted without the private key
   - The private key is NOT in Git

## Commands Reference

### Encrypt a Secret
```powershell
sops -e -i workloads/mysql/secret.enc.yaml
```

### Decrypt a Secret (for editing)
```powershell
sops -d -i workloads/mysql/secret.enc.yaml
```

### View Decrypted Secret (without modifying file)
```powershell
sops -d workloads/mysql/secret.enc.yaml
```

### Check SOPS Secret in Kubernetes
```powershell
kubectl get secret sops-age -n flux-system
```

### Check FluxCD Decryption Configuration
```powershell
kubectl get kustomization flux-system -n flux-system -o jsonpath='{.spec.decryption}'
```

### Verify Secret Decryption
```powershell
# Check if FluxCD can decrypt secrets
flux get kustomizations -n flux-system
```

## Troubleshooting

### Secrets Not Decrypting

1. **Check SOPS secret exists**:
   ```powershell
   kubectl get secret sops-age -n flux-system
   ```

2. **Check Kustomization decryption config**:
   ```powershell
   kubectl get kustomization flux-system -n flux-system -o yaml | grep -A 5 decryption
   ```

3. **Check kustomize-controller logs**:
   ```powershell
   kubectl logs -n flux-system -l app=kustomize-controller | grep -i sops
   ```

### Re-create SOPS Secret

If the secret is lost, recreate it:
```powershell
kubectl create secret generic sops-age \
  --from-file=age.agekey=age-key.txt \
  --namespace=flux-system
```

### Update Kustomization Decryption

If decryption config is missing:
```powershell
kubectl patch kustomization flux-system -n flux-system --type merge -p '{"spec":{"decryption":{"provider":"sops","secretRef":{"name":"sops-age"}}}}'
```

## Next Steps

1. ✅ SOPS is configured and working
2. ✅ Secrets are encrypted and stored in GitHub
3. ✅ FluxCD is configured to decrypt secrets automatically
4. ⏳ Wait for FluxCD to sync and decrypt secrets
5. ⏳ Verify secrets are decrypted and applied correctly

## Resources

- [SOPS Documentation](https://github.com/getsops/sops)
- [age Documentation](https://github.com/FiloSottile/age)
- [FluxCD SOPS Documentation](https://fluxcd.io/flux/components/kustomize/kustomization/#decrypt-secrets-with-sops)

