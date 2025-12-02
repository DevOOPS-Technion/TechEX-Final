# TechEX - Complete User Guide

This guide provides step-by-step instructions for deploying and using TechEX.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Initial Setup](#2-initial-setup)
3. [Configure GitHub Secrets](#3-configure-github-secrets)
4. [Deploy the Application](#4-deploy-the-application)
5. [Find the Application URL](#5-find-the-application-url)
6. [Using the Application](#6-using-the-application)
7. [API Endpoints](#7-api-endpoints)
8. [Troubleshooting](#8-troubleshooting)
9. [Cleanup](#9-cleanup)

---

## 1. Prerequisites

Before starting, ensure you have:

### Required Accounts
- **GitHub Account** - To host the repository
- **Docker Hub Account** - To store the container image
- **AWS Academy Account** - To deploy infrastructure

### Required Tools (Windows)
- **Git** - [Download](https://git-scm.com/download/win)
- **Docker Desktop** (optional, for local testing) - [Download](https://www.docker.com/products/docker-desktop/)

### Verify Installation
Open PowerShell and run:
```powershell
git --version
```

---

## 2. Initial Setup

### Step 2.1: Clone the Repository

```powershell
# Clone your repository
git clone https://github.com/DevOOPS-Technion/TechEX-Final.git

# Navigate to the project folder
cd TechEX-Final
```

### Step 2.2: Run Setup Helper

```powershell
# Run the deployment helper script
.\deploy.ps1 -SetupSecrets
```

This creates a `SECRETS_TEMPLATE.txt` file with the required secrets.

---

## 3. Configure GitHub Secrets

### Step 3.1: Get Your AWS Academy Credentials

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

### Step 3.2: Get Docker Hub Token

1. Go to [Docker Hub](https://hub.docker.com/)
2. Click your username → **Account Settings**
3. Click **Security** → **New Access Token**
4. Give it a name (e.g., "TechEX") and click **Generate**
5. Copy the token (you won't see it again!)

### Step 3.3: Add Secrets to GitHub

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

### Step 3.4: Update AWS Credentials (Before Each Deploy)

Since AWS Academy credentials expire, update them before deploying:

1. Go to AWS Academy → Learner Lab → AWS Details → Show
2. In GitHub → Settings → Secrets → Actions
3. Update these 3 secrets with new values:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN`

---

## 4. Deploy the Application

### Step 4.1: Make Sure AWS Credentials Are Fresh

Before deploying, ensure your AWS Academy lab is **started** and credentials are updated in GitHub secrets.

### Step 4.2: Commit and Push

```powershell
# Stage all files
git add .

# Commit changes
git commit -m "Deploy TechEX application"

# Push to GitHub (triggers CI/CD)
git push origin main
```

### Step 4.3: Monitor the Pipeline

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

## 5. Find the Application URL

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

### Step 5.1: Test the Application

Open your browser and go to:
```
http://<your-load-balancer-dns>
```

### Step 5.2: Verify Health

Open a new browser tab:
```
http://<your-load-balancer-dns>/health
```

You should see:
```json
{
  "status": "healthy",
  "version": "2.0",
  "timestamp": "2025-12-01T12:00:00",
  "data_persistence": true
}
```

---

## 6. Using the Application

### 6.1 Home Page

**URL:** `http://<load-balancer-dns>/`

- View welcome message
- See quick statistics
- Navigate to other pages

### 6.2 View All Parcels

**URL:** `http://<load-balancer-dns>/parcels`

- See all parcels in the system
- View tracking numbers, status, cost
- Click **Edit** to modify a parcel
- Click **Remove** to delete a parcel

### 6.3 Add New Parcel

**URL:** `http://<load-balancer-dns>/add_parcel`

Fill in the form with:

| Field | Description | Example |
|-------|-------------|---------|
| Tracking Number | Unique ID | TXP-2025-007 |
| Sender | Sender name | Shenzhen Express |
| Receiver | Recipient name | John Doe |
| Origin | Where from | Shenzhen, China |
| Destination | Where to | Tel Aviv, Israel |
| Cost (₪) | Shipping cost | 25.50 |
| Weight (kg) | Package weight | 1.5 |
| Dispatch Date | Date sent | 2025-12-01 |

Click **Add Parcel** to save.

### 6.4 Edit a Parcel

**URL:** `http://<load-balancer-dns>/edit_parcel/<id>`

You can update:
- **Status** - Pending or Delivered
- **Delivery Date** - When delivered
- **Cost** - Shipping cost
- **Weight** - Package weight

### 6.5 View Statistics

**URL:** `http://<load-balancer-dns>/statistics`

See:
- Total number of parcels
- Delivered vs Pending count
- Total cost and weight
- Average cost and weight
- Delivery rate percentage

---

## 7. API Endpoints

### Get All Parcels (JSON)

```bash
curl http://<load-balancer-dns>/api/parcels
```

Response:
```json
[
  {
    "id": "1",
    "tracking_number": "TXP-2025-001",
    "sender": "Shanghai Express",
    "receiver": "David Cohen",
    "status": "delivered",
    "cost": 24.50,
    "weight": 1.8
  }
]
```

### Health Check

```bash
curl http://<load-balancer-dns>/health
```

### Readiness Check

```bash
curl http://<load-balancer-dns>/ready
```

---

## 8. Troubleshooting

### Problem: Pipeline Fails at "Infrastructure" Stage

**Cause:** AWS credentials expired or invalid

**Solution:**
1. Go to AWS Academy → Start Lab (if stopped)
2. Get fresh credentials (AWS Details → Show)
3. Update all 3 AWS secrets in GitHub:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN`
4. Re-run the workflow

### Problem: "ExpiredTokenException" Error

**Cause:** AWS session token expired (they last ~4 hours)

**Solution:** Same as above - get fresh credentials from AWS Academy

### Problem: Application Not Loading (502/503 Error)

**Solution:**
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

**Solution:**
```bash
# SSH to master
ssh -i techex.pem ubuntu@<master-ip>

# Check NFS share
ls -la /srv/nfs/techex-data/

# Check if file exists
cat /srv/nfs/techex-data/parcels.json
```

### Problem: Workers Not Joining Cluster

**Solution:**
```bash
# On master, check join command
cat /home/ubuntu/join-command.sh

# Check nodes status
kubectl get nodes

# Check kubelet on worker
ssh ubuntu@<worker-ip> 'sudo systemctl status kubelet'
```

---

## 9. Cleanup

### Delete All AWS Resources

**Option A: Using Terraform (Recommended)**

First, update AWS credentials, then:

```powershell
cd terraform
terraform destroy -auto-approve
```

**Option B: Manual via AWS Console**

1. **Delete EC2 Instances**
   - Go to EC2 → Instances
   - Select all `techex-*` instances
   - Actions → Terminate

2. **Delete Load Balancer**
   - Go to EC2 → Load Balancers
   - Select `techex-lb` → Actions → Delete

3. **Delete Target Group**
   - Go to EC2 → Target Groups
   - Select `techex-tg` → Actions → Delete

4. **Delete Security Groups**
   - Go to EC2 → Security Groups
   - Delete `techex-*` security groups (delete non-default ones)

5. **Delete VPC**
   - Go to VPC → Your VPCs
   - Select `techex-vpc` → Actions → Delete VPC

### Clean Docker Hub (Optional)

1. Go to Docker Hub → Repositories
2. Delete `<username>/techex`

---

## Quick Reference

| Action | URL |
|--------|-----|
| Home | `/` |
| View Parcels | `/parcels` |
| Add Parcel | `/add_parcel` |
| Statistics | `/statistics` |
| Health Check | `/health` |
| API | `/api/parcels` |

---

## GitHub Secrets Summary

| Secret | Where to Get |
|--------|--------------|
| `AWS_ACCESS_KEY_ID` | AWS Academy → Learner Lab → AWS Details |
| `AWS_SECRET_ACCESS_KEY` | AWS Academy → Learner Lab → AWS Details |
| `AWS_SESSION_TOKEN` | AWS Academy → Learner Lab → AWS Details |
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub → Account Settings → Security |

---

**📦 Happy Parcel Tracking!**
