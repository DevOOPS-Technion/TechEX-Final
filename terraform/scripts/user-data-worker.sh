#!/bin/bash
# ============================================
# TechEX - Worker Node Bootstrap
# ============================================

set -e
exec > >(tee /var/log/techex-setup.log) 2>&1

echo "[TechEX] Starting worker setup - $(date)"

# Terraform variable
MASTER_IP="${control_plane_ip}"

# Get instance ID for unique hostname
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id | tail -c 8)
hostnamectl set-hostname "techex-worker-$INSTANCE_ID"

# System prep
apt-get update -qq
apt-get install -y -qq apt-transport-https ca-certificates curl gnupg lsb-release nfs-common

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Kernel modules
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

# Network settings
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

# ============================================
# Setup NFS Mount Point
# ============================================
echo "[TechEX] Configuring NFS client..."

mkdir -p /mnt/techex-data
echo "$MASTER_IP:/srv/nfs/techex-data /mnt/techex-data nfs defaults,_netdev 0 0" >> /etc/fstab

# Worker is ready - cluster join happens via Ansible
echo "[TechEX] Worker setup complete! Waiting for cluster join... - $(date)"
