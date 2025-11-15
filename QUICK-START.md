# Quick Start Guide

This guide provides a condensed version of the setup process. For detailed instructions, see [SETUP.md](SETUP.md).

## Prerequisites

- k3s (or k3d for Windows), kubectl, flux CLI, SOPS, age installed
- GitHub repository created
- GitHub personal access token

## Setup Checklist

- [ ] **Step 1**: Create k3s cluster
  ```bash
  # Linux/macOS/WSL2
  curl -sfL https://get.k3s.io | sh -
  sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
  sudo chown $USER ~/.kube/config
  
  # Or Windows with k3d
  k3d cluster create local-dev --port "80:80@loadbalancer" --port "443:443@loadbalancer"
  k3d kubeconfig merge local-dev
  ```

- [ ] **Step 2**: Generate age keys
  ```bash
  age-keygen -o age-key.txt
  age-keygen -y age-key.txt  # Copy the public key
  ```

- [ ] **Step 3**: Update `.sops.yaml` and `clusters/local/flux-system/.sops.yaml` with public key

- [ ] **Step 4**: Update MySQL and WordPress secrets with your credentials (in `secret.enc.yaml` files)

- [ ] **Step 5**: Encrypt secrets
  ```bash
  sops -e -i workloads/mysql/secret.enc.yaml
  sops -e -i workloads/wordpress/secret.enc.yaml
  ```

- [ ] **Step 6**: Update `clusters/local/flux-system/gotk-sync.yaml` with your GitHub repo details

- [ ] **Step 7**: Commit and push to GitHub
  ```bash
  git add .
  git commit -m "Initial setup"
  git push
  ```

- [ ] **Step 8**: Create SOPS secret in Kubernetes
  ```bash
  kubectl create secret generic sops-age \
    --from-file=age.agekey=age-key.txt \
    --namespace=flux-system
  ```

- [ ] **Step 9**: Bootstrap FluxCD
  ```bash
  flux bootstrap github \
    --owner=YOUR_USERNAME \
    --repository=YOUR_REPO_NAME \
    --branch=main \
    --path=./clusters/local \
    --personal
  ```

- [ ] **Step 10**: Update MetalLB IP pool in `infrastructure/metallb/ipaddresspool.yaml` if needed

- [ ] **Step 11**: Monitor deployment
  ```bash
  flux get kustomizations
  kubectl get pods -A -w
  ```

- [ ] **Step 12**: Get LoadBalancer IP and update `/etc/hosts`
  ```bash
  kubectl get svc -n ingress-nginx ingress-nginx-controller
  # Add IP to /etc/hosts: <IP> app.local
  ```

- [ ] **Step 13**: Access WordPress at http://app.local

## Verify Setup

Run the verification script:
```bash
chmod +x scripts/verify-setup.sh
./scripts/verify-setup.sh
```

## Key Commands

```bash
# Check FluxCD status
flux get kustomizations
flux get sources git
flux get helmreleases

# Force sync
flux reconcile kustomization flux-system --with-source

# View logs
kubectl logs -n flux-system -l app=kustomize-controller
kubectl logs -n flux-system -l app=helm-controller

# Check resources
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
```

## File Structure

```
.
├── clusters/
│   ├── k3s/               # k3s cluster setup instructions
│   └── local/             # FluxCD cluster config
│       ├── flux-system/   # FluxCD bootstrap
│       └── kustomization.yaml
├── infrastructure/
│   ├── metallb/           # Load balancer
│   └── ingress-nginx/     # Ingress controller
├── workloads/
│   ├── mysql/             # MySQL database
│   └── wordpress/         # WordPress app
├── scripts/               # Setup scripts
└── README.md              # Full documentation
```

## Troubleshooting

**FluxCD not syncing?**
```bash
flux reconcile source git flux-system
flux reconcile kustomization flux-system
```

**SOPS decryption failing?**
```bash
kubectl get secret sops-age -n flux-system
kubectl logs -n flux-system -l app=kustomize-controller | grep -i sops
```

**MySQL connection issues?**
```bash
kubectl logs -n mysql -l app=mysql
kubectl get secret mysql-secret -n mysql
```

**MetalLB not assigning IPs?**
```bash
kubectl get ipaddresspool -n metallb-system
kubectl logs -n metallb-system -l app=metallb
```

