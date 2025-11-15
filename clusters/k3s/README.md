# k3s Cluster Setup

k3s is a lightweight Kubernetes distribution designed for resource-constrained environments and edge computing.

## Installation

### Linux/macOS

```bash
curl -sfL https://get.k3s.io | sh -
```

### Windows (using WSL2 or via Docker)

For Windows, k3s can be run in WSL2 or via Docker:

**Option 1: WSL2**
```bash
# Inside WSL2
curl -sfL https://get.k3s.io | sh -
```

**Option 2: Docker (using k3d)**
```bash
# Install k3d (k3s in Docker)
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d cluster create local-dev --port "80:80@loadbalancer" --port "443:443@loadbalancer"
```

## Post-Installation

After installing k3s, configure kubectl:

```bash
# Linux/macOS/WSL2
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Or copy kubeconfig to default location
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
```

For Windows with k3d:
```bash
k3d kubeconfig merge local-dev --kubeconfig-merge-default
```

## Verify Installation

```bash
kubectl get nodes
kubectl get pods -A
```

## Network Configuration

k3s uses Flannel CNI by default. MetalLB will need an IP pool configured for your network interface.

Typical IP ranges for k3s:
- Default bridge network: Check with `ip addr` or `ifconfig`
- For local development: Usually use a range in your local subnet

Example:
```yaml
addresses:
  - 192.168.1.200-192.168.1.250
```

