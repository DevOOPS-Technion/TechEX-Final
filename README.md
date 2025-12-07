<p align="center">
  <img src="web/assets/TechEX_dark.png" alt="TechEX Logo" width="400" />
</p>

# TechEX - Parcel Management System

**DevOps Final Project** | Kubernetes on AWS with Full CI/CD Automation

---

## Project Info

| Field | Value |
|-------|-------|
| **Name** | Alex Ivanov |
| **GitHub** | [TechEX-Final](https://github.com/DevOOPS-Technion/TechEX-Final) |

---

## Table of Contents

1. [Architecture](#architecture)
2. [Prerequisites](#prerequisites)
3. [Clone the Repository](#clone-the-repository)
4. [Configure GitHub Secrets](#configure-github-secrets)
5. [Deploy](#deploy)
6. [Find the Application URL](#find-the-application-url)
7. [Troubleshooting](#troubleshooting)
8. [Cleanup](#cleanup)

---

## Architecture

```
                    Internet
                        │
              ┌─────────▼─────────┐
              │   Load Balancer   │  ← Port 80
              │   (AWS ALB)       │
              └─────────┬─────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
   ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
   │ Master  │    │ Worker1 │    │ Worker2 │
   │10.0.1.10│    │10.0.1.11│    │10.0.2.11│
   │ +NFS    │    │NodePort │    │NodePort │
   └────┬────┘    └────┬────┘    └────┬────┘
        │              │              │
        └──────────────┴──────────────┘
                   NFS Share
              /srv/nfs/techex-data
```

### CI/CD Pipeline

| Stage | Description |
|-------|-------------|
| **1. Test** | Run Python unit tests |
| **2. Build** | Build & push Docker image to Docker Hub |
| **3. Infrastructure** | Terraform provisions 3 EC2s + ALB |
| **4. Configure** | Join workers to K8s cluster + mount NFS |
| **5. Deploy** | Helm deploys app to Kubernetes |

### Components

| Component | Version |
|-----------|---------|
| Kubernetes | 1.29 |
| Terraform | 1.6+ |
| Flask | 3.0 |
| Python | 3.11 |
| Ubuntu | 22.04 |

---

## Prerequisites

### Required Accounts
- **GitHub Account** - To host the repository
- **Docker Hub Account** - To store the container image
- **AWS Academy Account** - To deploy infrastructure

### Required Tools (Windows)
- **Git** - [Download](https://git-scm.com/download/win)
- **Docker Desktop** (optional, for local testing) - [Download](https://www.docker.com/products/docker-desktop/)

### Verify Installation
```powershell
git --version
```

---

## Clone the Repository

```powershell
# Clone the repository (or fork it first)
git clone https://github.com/DevOOPS-Technion/TechEX-Final.git

# Navigate to the project folder
cd TechEX-Final
```

---

## Configure GitHub Secrets

### Step 1: Get Your AWS Academy Credentials

1. Go to [AWS Academy](https://awsacademy.instructure.com/)
2. Open your **Learner Lab**
3. Click **AWS Details** (on the right side)
4. Click **Show** next to AWS CLI
5. You'll see:
   ```
   [default]
   aws_access_key_id=ASIA...
   aws_secret_access_key=...
   aws_session_token=...
   ```
6. Copy each value

⚠️ **Important:** AWS Academy credentials expire every ~4 hours. You'll need to update them before each deployment.

### Step 2: Get Docker Hub Token

1. Go to [Docker Hub](https://hub.docker.com/)
2. Click your username → **Account Settings**
3. Click **Security** → **New Access Token**
4. Give it a name (e.g., "TechEX") and click **Generate**
5. Copy the token (you won't see it again!)

### Step 3: Add Secrets to GitHub

1. Go to your GitHub repository
2. Click **Settings** (tab)
3. Click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add these **5 secrets** one by one:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | `ASIA...` | From AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | (long string) | From AWS Academy |
| `AWS_SESSION_TOKEN` | (very long string) | From AWS Academy |
| `DOCKERHUB_USERNAME` | Your username | Docker Hub username |
| `DOCKERHUB_TOKEN` | Your token | Docker Hub access token |

### Updating AWS Credentials (Before Each Deploy)

Since AWS Academy credentials expire, update them before deploying:

1. Go to AWS Academy → Learner Lab → AWS Details → Show
2. In GitHub → Settings → Secrets → Actions
3. Update these 3 secrets with new values:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN`

---

## Deploy

### Step 1: Make Sure AWS Credentials Are Fresh

Before deploying, ensure your AWS Academy lab is **started** and credentials are updated in GitHub secrets.

### Step 2: Commit and Push

```powershell
# Stage all files
git add .

# Commit changes
git commit -m "Deploy TechEX application"

# Push to GitHub (triggers CI/CD)
git push origin main
```

### Step 3: Monitor the Pipeline

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click on the running workflow "TechEX Deploy"
4. Watch all 5 stages complete:
   - ✅ 1. Test
   - ✅ 2. Build
   - ✅ 3. Infrastructure
   - ✅ 4. Configure
   - ✅ 5. Deploy

⏱️ **Total time: ~15-20 minutes**

---

## Find the Application URL

### Option A: From GitHub Actions

1. Go to **Actions** → Latest workflow run
2. Click on **5. Deploy** job
3. Expand **Summary** step
4. Find the URL:
   ```
   🌐 Application URL:
      http://techex-lb-XXXXXXXXXX.us-east-1.elb.amazonaws.com
   ```

### Option B: From AWS Console

1. Go to [AWS Console](https://console.aws.amazon.com/) (via AWS Academy)
2. Navigate to **EC2** → **Load Balancers**
3. Find `techex-lb`
4. Copy the **DNS name**

### Verify Health

```bash
curl http://<your-load-balancer-dns>/health
```

Expected response:
```json
{
  "status": "healthy",
  "version": "2.0",
  "data_persistence": true
}
```

---

> ## 📚 [**Using the Application →**](APPLICATION_GUIDE.md)
> 
> Once deployed, see the **[Application Guide](APPLICATION_GUIDE.md)** to learn how to:
> - Navigate the web interface
> - Add and manage parcels
> - View statistics
> - Use the API endpoints

---

## Troubleshooting

### Problem: Pipeline Fails at "Infrastructure" Stage

**Cause:** AWS credentials expired or invalid

**Solution:**
1. Go to AWS Academy → Start Lab (if stopped)
2. Get fresh credentials (AWS Details → Show)
3. Update all 3 AWS secrets in GitHub
4. Re-run the workflow

### Problem: "ExpiredTokenException" Error

**Cause:** AWS session token expired (they last ~4 hours)

**Solution:** Same as above - get fresh credentials from AWS Academy

### Problem: Application Not Loading (502/503 Error)

Wait 5-10 minutes for health checks to pass, then:

```powershell
# SSH to master (get IP from GitHub Actions output)
ssh -i techex.pem ubuntu@<master-ip>

# Check if pods are running
kubectl get pods -n techex

# Check pod logs
kubectl logs -n techex -l app=techex

# Check nodes
kubectl get nodes
```

### Problem: Data Not Persisting

```bash
# SSH to master
ssh -i techex.pem ubuntu@<master-ip>

# Check NFS share
ls -la /srv/nfs/techex-data/

# Check if file exists
cat /srv/nfs/techex-data/parcels.json
```

### Problem: Workers Not Joining Cluster

```bash
# On master, check join command
cat /home/ubuntu/join-command.sh

# Check nodes status
kubectl get nodes

# Check kubelet on worker
ssh ubuntu@<worker-ip> 'sudo systemctl status kubelet'
```

---

## Cleanup

### Option A: Using Terraform (Recommended)

First, update AWS credentials, then:

```powershell
cd terraform
terraform destroy -auto-approve
```

### Option B: Manual via AWS Console

1. **EC2 → Instances** → Terminate all `techex-*` instances
2. **EC2 → Load Balancers** → Delete `techex-lb`
3. **EC2 → Target Groups** → Delete `techex-tg`
4. **EC2 → Security Groups** → Delete `techex-*` groups
5. **VPC → Your VPCs** → Delete `techex-vpc`

---

## Project Structure

```
TechEX-Final/
├── .github/workflows/cicd.yml    # CI/CD Pipeline (5 stages)
├── ansible/                      # Worker config (join + NFS)
├── docker/Dockerfile             # Application container
├── terraform/                    # AWS Infrastructure
│   ├── *.tf                      # Terraform configs
│   └── scripts/                  # EC2 bootstrap scripts
├── web/                          # Flask application
├── APPLICATION_GUIDE.md          # Web app usage guide
└── README.md                     # This file
```

---

**Built for DevOps Course** 🎓
