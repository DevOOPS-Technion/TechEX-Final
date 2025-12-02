#!/bin/bash
# ============================================
# TechEX - Control Plane Bootstrap
# Kubernetes Master + NFS Server Setup
# ============================================

set -e
exec > >(tee /var/log/techex-setup.log) 2>&1

echo "[TechEX] Starting control plane setup - $(date)"

# Terraform variables
DOCKER_IMG="${docker_image}"
MASTER_IP="${control_plane_ip}"
POD_NET="${pod_cidr}"

# Set hostname
hostnamectl set-hostname techex-master

# System prep
apt-get update -qq
apt-get install -y -qq apt-transport-https ca-certificates curl gnupg lsb-release jq

# Disable swap (required for K8s)
swapoff -a
sed -i '/swap/d' /etc/fstab

# Kernel modules for container networking
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# Network settings for K8s
cat > /etc/sysctl.d/99-kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF
sysctl --system

# ============================================
# Install Containerd
# ============================================
echo "[TechEX] Installing containerd..."

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -qq
apt-get install -y -qq containerd.io

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# ============================================
# Install Kubernetes
# ============================================
echo "[TechEX] Installing Kubernetes components..."

mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/k8s.gpg
echo "deb [signed-by=/etc/apt/keyrings/k8s.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
apt-get update -qq
apt-get install -y -qq kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet

# Initialize cluster
echo "[TechEX] Initializing Kubernetes cluster..."
kubeadm init --apiserver-advertise-address=$MASTER_IP --pod-network-cidr=$POD_NET --ignore-preflight-errors=NumCPU

# Setup kubeconfig
mkdir -p /home/ubuntu/.kube /root/.kube
cp /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
cp /etc/kubernetes/admin.conf /root/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Install Flannel CNI
echo "[TechEX] Installing Flannel network..."
kubectl --kubeconfig=/root/.kube/config apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Wait for master to be ready
echo "[TechEX] Waiting for master node..."
sleep 45
kubectl --kubeconfig=/root/.kube/config wait --for=condition=Ready node --all --timeout=300s || true

# Generate and save join command
kubeadm token create --print-join-command > /home/ubuntu/join-command.sh
chmod 755 /home/ubuntu/join-command.sh
chown ubuntu:ubuntu /home/ubuntu/join-command.sh

# ============================================
# Setup NFS Server
# ============================================
echo "[TechEX] Setting up NFS server..."

apt-get install -y -qq nfs-kernel-server
mkdir -p /srv/nfs/techex-data
chmod 777 /srv/nfs/techex-data

# Create dummy data for initial deployment
cat > /srv/nfs/techex-data/parcels.json <<'DATAEOF'
[
  {"id":"1","tracking_number":"TXP-2025-001","sender":"Shanghai Express","receiver":"David Cohen","origin":"Shanghai, China","destination":"Tel Aviv, Israel","status":"delivered","cost":24.50,"weight":1.8,"dispatch_date":"2025-07-15","delivery_date":"2025-07-28"},
  {"id":"2","tracking_number":"TXP-2025-002","sender":"Beijing Cargo","receiver":"Sarah Levi","origin":"Beijing, China","destination":"Haifa, Israel","status":"delivered","cost":31.00,"weight":2.5,"dispatch_date":"2025-07-18","delivery_date":"2025-07-30"},
  {"id":"3","tracking_number":"TXP-2025-003","sender":"Guangzhou Shipping","receiver":"Michael Ben-Ari","origin":"Guangzhou, China","destination":"Jerusalem, Israel","status":"pending","cost":18.75,"weight":0.9,"dispatch_date":"2025-08-01","delivery_date":null},
  {"id":"4","tracking_number":"TXP-2025-004","sender":"Shenzhen Logistics","receiver":"Rachel Mizrahi","origin":"Shenzhen, China","destination":"Netanya, Israel","status":"delivered","cost":27.25,"weight":3.1,"dispatch_date":"2025-07-20","delivery_date":"2025-08-02"},
  {"id":"5","tracking_number":"TXP-2025-005","sender":"Hong Kong Post","receiver":"Yossi Shapira","origin":"Hong Kong","destination":"Beersheba, Israel","status":"pending","cost":22.00,"weight":1.4,"dispatch_date":"2025-08-03","delivery_date":null},
  {"id":"6","tracking_number":"TXP-2025-006","sender":"Taiwan Express","receiver":"Noa Goldberg","origin":"Taipei, Taiwan","destination":"Eilat, Israel","status":"delivered","cost":35.50,"weight":4.2,"dispatch_date":"2025-07-12","delivery_date":"2025-07-25"}
]
DATAEOF

chown -R nobody:nogroup /srv/nfs/techex-data
echo "/srv/nfs/techex-data 10.0.0.0/16(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
exportfs -ra
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

# ============================================
# Install Helm
# ============================================
echo "[TechEX] Installing Helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Create directory for helm chart (will be copied by CI/CD)
mkdir -p /home/ubuntu/charts
chown -R ubuntu:ubuntu /home/ubuntu/charts

echo "[TechEX] Control plane setup complete! - $(date)"
echo "[TechEX] Waiting for Helm chart to be copied by CI/CD..."
