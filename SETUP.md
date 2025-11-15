# Step-by-Step Setup Guide

Follow these steps in order to complete Task 1.

## Prerequisites Check

```bash
# Check if k3s is installed (Linux/macOS/WSL2)
k3s --version
# or for Windows with k3d
k3d version

# Check if kubectl is installed
kubectl version --client

# Check if flux is installed (install if not)
flux --version
# Install: curl -s https://fluxcd.io/install.sh | bash

# Check if sops is installed (install if not)
sops --version
# Install: https://github.com/getsops/sops/releases

# Check if age is installed (install if not)
age --version
# Install: https://github.com/FiloSottile/age
```

## Step 1: Create k3s Cluster

**Linux/macOS:**
```bash
curl -sfL https://get.k3s.io | sh -

# Configure kubectl
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
```

**Windows (WSL2):**
```bash
# Inside WSL2
curl -sfL https://get.k3s.io | sh -
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
```

**Windows (Docker/k3d):**
```bash
# Install k3d first: https://k3d.io
k3d cluster create local-dev --port "80:80@loadbalancer" --port "443:443@loadbalancer"
k3d kubeconfig merge local-dev --kubeconfig-merge-default
```

**Or use the setup script:**
- Linux/macOS/WSL2: `./scripts/setup-k3s.sh`
- Windows: `.\scripts\setup-k3s.ps1`

Verify cluster is running:
```bash
kubectl cluster-info
kubectl get nodes
```

## Step 2: Generate Age Keys for SOPS

```bash
# Generate age key pair
age-keygen -o age-key.txt

# Display public key
age-keygen -y age-key.txt
```

**IMPORTANT**: Save the public key output. You'll need it in the next step.

**NEVER commit `age-key.txt` to Git!**

## Step 3: Configure SOPS

Update the following files with your **PUBLIC_KEY** (from Step 2):

1. **`.sops.yaml`**: Replace `PUBLIC_KEY_HERE` with your public key
2. **`clusters/local/flux-system/.sops.yaml`**: Replace `PUBLIC_KEY_HERE` with your public key

Example:
```yaml
age: age1abc123def456...  # Your public key here
```

## Step 4: Create MySQL Secret (Unencrypted)

Create or edit `workloads/mysql/secret.enc.yaml` with your desired MySQL credentials (it's currently unencrypted):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: mysql
type: Opaque
stringData:
  root-password: your_root_password_here
  username: wordpress
  password: your_wordpress_password_here
```

**Important**: The `username` and `password` values must match what WordPress will use.

## Step 5: Create WordPress Secret (Unencrypted)

Create or edit `workloads/wordpress/secret.enc.yaml` with matching credentials:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wordpress-db-secret
  namespace: wordpress
type: Opaque
stringData:
  username: wordpress  # Must match MySQL secret username
  password: your_wordpress_password_here  # Must match MySQL secret password
```

## Step 6: Encrypt Secrets with SOPS

```bash
# On Linux/Mac:
chmod +x scripts/encrypt-secret.sh
./scripts/encrypt-secret.sh

# On Windows (PowerShell):
# You'll need to use SOPS directly:
sops -e -i workloads/mysql/secret.enc.yaml
sops -e -i workloads/wordpress/secret.enc.yaml
```

Verify encryption:
```bash
# The files should now be encrypted (binary format)
cat workloads/mysql/secret.enc.yaml
```

## Step 7: Update GitHub Repository Configuration

Before bootstrapping FluxCD, update these files:

1. **`clusters/local/flux-system/gotk-sync.yaml`**:
   - Replace `YOUR_USERNAME` with your GitHub username
   - Replace `YOUR_REPO_NAME` with your repository name

Example:
```yaml
url: https://github.com/johndoe/my-gitops-repo
```

## Step 8: Initialize Git Repository and Push to GitHub

```bash
# Initialize git (if not already done)
git init

# Add all files (except age-key.txt)
git add .

# Commit
git commit -m "Initial GitOps setup with FluxCD, MySQL, and WordPress"

# Add remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Push to GitHub
git push -u origin main
```

## Step 9: Create SOPS Secret in Kubernetes

FluxCD needs access to the age private key to decrypt SOPS-encrypted files:

```bash
# Create the secret from your age-key.txt
kubectl create secret generic sops-age \
  --from-file=age.agekey=age-key.txt \
  --namespace=flux-system \
  --dry-run=client -o yaml | kubectl apply -f -
```

**For FluxCD to automatically decrypt SOPS files**, you need to reference this secret in your Kustomization. However, FluxCD's kustomize-controller will automatically decrypt SOPS-encrypted files if:

1. The `.sops.yaml` file exists in the same directory or parent directories
2. The `sops-age` secret exists in the `flux-system` namespace with the age key at `age.agekey`

## Step 10: Bootstrap FluxCD

**Important**: Make sure all files are committed and pushed to GitHub before bootstrapping!

```bash
# Bootstrap FluxCD with GitHub
flux bootstrap github \
  --owner=YOUR_GITHUB_USERNAME \
  --repository=YOUR_REPO_NAME \
  --branch=main \
  --path=./clusters/local \
  --personal
```

This will:
- Install FluxCD components in your cluster
- Create a GitHub deploy key
- Configure FluxCD to sync from your repository
- Set up the GitRepository and Kustomization resources

## Step 11: Configure MetalLB IP Address Pool

Update `infrastructure/metallb/ipaddresspool.yaml` with appropriate IP range for your k3s cluster:

**Determine your network IP range:**
```bash
# Linux/macOS/WSL2
ip addr show
# or
ifconfig

# Look for your primary network interface (usually eth0, ens33, or similar)
# Note the network subnet (e.g., 192.168.1.0/24)
```

**Configure MetalLB IP pool:**
Use an IP range in your local subnet that doesn't conflict with existing IPs. For example, if your network is `192.168.1.0/24`:
```yaml
addresses:
  - 192.168.1.200-192.168.1.250
```

**Important:** 
- The IP range must be in the same subnet as your k3s nodes
- Don't use IPs that are already assigned or in DHCP range
- For k3d (Docker), you may need to use Docker bridge network range: `172.18.0.0/16` or similar

## Step 12: Update WordPress Deployment

Ensure `workloads/wordpress/deployment.yaml` has the correct database credentials that match your MySQL secret.

## Step 13: Commit and Push All Changes

```bash
git add .
git commit -m "Configure MetalLB and update secrets"
git push
```

## Step 14: Monitor FluxCD Sync

```bash
# Check FluxCD sync status
flux get kustomizations

# Check GitRepository sync
flux get sources git

# Check HelmReleases
flux get helmreleases

# Force reconciliation if needed
flux reconcile kustomization flux-system --with-source
```

## Step 15: Monitor Deployment Progress

```bash
# Watch all pods
kubectl get pods -A -w

# Check specific namespaces
kubectl get pods -n flux-system
kubectl get pods -n metallb-system
kubectl get pods -n ingress-nginx
kubectl get pods -n mysql
kubectl get pods -n wordpress

# Check services
kubectl get svc -A

# Check ingress
kubectl get ingress -A
```

## Step 16: Get LoadBalancer IP

Wait for MetalLB to assign an IP to ingress-nginx:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

Note the `EXTERNAL-IP` value.

## Step 17: Configure /etc/hosts

Add the LoadBalancer IP to your hosts file:

**Linux/Mac** (`/etc/hosts`):
```
<LOADBALANCER_IP> app.local
```

**Windows** (`C:\Windows\System32\drivers\etc\hosts`):
```
<LOADBALANCER_IP> app.local
```

Replace `<LOADBALANCER_IP>` with the IP from Step 16.

## Step 18: Access WordPress

Open your browser and navigate to:
```
http://app.local
```

You should see the WordPress installation page!

## Troubleshooting

### FluxCD not syncing
```bash
flux reconcile source git flux-system
flux reconcile kustomization flux-system
```

### Check SOPS decryption
```bash
# Verify secret exists
kubectl get secret sops-age -n flux-system

# Check kustomize-controller logs
kubectl logs -n flux-system -l app=kustomize-controller | grep -i sops
```

### MySQL connection issues
```bash
# Check MySQL pod logs
kubectl logs -n mysql -l app=mysql

# Verify secret is decrypted
kubectl get secret mysql-secret -n mysql -o yaml
```

### MetalLB not assigning IPs
```bash
# Check MetalLB logs
kubectl logs -n metallb-system -l app=metallb

# Verify IPAddressPool
kubectl get ipaddresspool -n metallb-system
kubectl describe ipaddresspool default-pool -n metallb-system
```

### Ingress not working
```bash
# Check ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller

# Verify ingress resource
kubectl describe ingress wordpress-ingress -n wordpress
```

## Next Steps

After successful deployment:
1. Complete WordPress installation through the web UI
2. Verify all resources are managed by FluxCD (not manually applied)
3. Test GitOps workflow by making a change, committing, and watching FluxCD sync

