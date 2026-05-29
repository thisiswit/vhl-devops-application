#!/usr/bin/env bash

set -euo pipefail

echo "Starting VM provisioning..."

export DEBIAN_FRONTEND=noninteractive

echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get install -y curl ca-certificates gnupg lsb-release apt-transport-https

echo "Installing k3s..."

if ! command -v k3s >/dev/null 2>&1; then
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
    --tls-san 127.0.0.1 \
    --tls-san localhost \
    --tls-san 192.168.56.10" \
    K3S_KUBECONFIG_MODE="644" \
    sh -
else
  echo "k3s is already installed."
fi

echo "Waiting for Kubernetes node to become ready..."
sudo k3s kubectl wait node --all --for=condition=Ready --timeout=120s

echo "Preparing kubeconfig for vagrant user..."
mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube

echo "Creating kubectl shortcut..."
if ! command -v kubectl >/dev/null 2>&1; then
  sudo ln -s /usr/local/bin/k3s /usr/local/bin/kubectl
fi

echo "Installing Helm..."

if ! command -v helm >/dev/null 2>&1; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo "Helm is already installed."
fi

echo "Validating installation..."
kubectl get nodes
helm version

echo "Provisioning finished successfully."