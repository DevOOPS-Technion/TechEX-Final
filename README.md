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

## Quick Start (Windows)

### Step 1: Clone & Setup

```powershell
git clone <your-repo-url>
cd TechEX-Final

# Run the setup helper
.\deploy.ps1 -SetupSecrets
```

### Step 2: Get AWS Academy Credentials

1. Go to [AWS Academy](https://awsacademy.instructure.com/)
2. Open the course & start the instance
3. Copy the 3 credentials

### Step 3: Add GitHub Secrets

Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**

Add these **5 secrets**:

| Secret | From |
|--------|------|
| `AWS_ACCESS_KEY_ID` | AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | AWS Academy |
| `AWS_SESSION_TOKEN` | AWS Academy |
| `DOCKERHUB_USERNAME` | Docker Hub |
| `DOCKERHUB_TOKEN` | Docker Hub |

### Step 4: Deploy

```powershell
git add .
git commit -m "Deploy TechEX"
git push origin main
```

### Step 5: Access Application

After ~15 minutes, check **GitHub Actions** for the Load Balancer URL:

```
http://<load-balancer-dns>
```

---

## ⚠️ Important: AWS Academy Credentials

AWS Academy credentials **expire every ~4 hours**. Before each deployment:

1. Make sure Lab is **Started** (green)
2. Get fresh credentials from **AWS Details → Show**
3. Update the 3 AWS secrets in GitHub

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
├── deploy.ps1                    # Windows helper script
└── README.md                     # This file
```

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

---

## CI/CD Pipeline

| Stage | Description |
|-------|-------------|
| **1. Test** | Run Python unit tests |
| **2. Build** | Build & push Docker image to Docker Hub |
| **3. Infrastructure** | Terraform provisions 3 EC2s + ALB |
| **4. Configure** | Join workers to K8s cluster + mount NFS |
| **5. Deploy** | Helm deploys app to Kubernetes |

---

## How to Find the Load Balancer URL

**Option 1: GitHub Actions**
- Go to Actions → Latest workflow run → Deploy job → "Summary" step

**Option 2: AWS Console**
- EC2 → Load Balancers → `techex-lb` → Copy DNS name

---

## Testing & Validation

### Health Check
```bash
curl http://<load-balancer-dns>/health
```

### Expected Response
```json
{
  "status": "healthy",
  "version": "2.0",
  "data_persistence": true
}
```

### All Endpoints

| URL | Description |
|-----|-------------|
| `/` | Home page |
| `/health` | Health check |
| `/parcels` | View all parcels |
| `/add_parcel` | Add new parcel |
| `/statistics` | View statistics |
| `/api/parcels` | JSON API |

---

## Troubleshooting

### "ExpiredTokenException" Error?

AWS Academy credentials expired. Get fresh ones and update GitHub secrets.

### Pipeline Fails?

1. **Check Secrets** - Verify all 5 GitHub secrets are correct
2. **Start Lab** - Make sure AWS Academy lab is running
3. **View Logs** - Click on failed job in GitHub Actions

### App Not Loading?

```bash
# SSH to master (get IP from GitHub Actions output)
ssh -i techex.pem ubuntu@<master-ip>

# Check pods
kubectl get pods -n techex

# Check logs
kubectl logs -n techex -l app=techex
```

---

## Cleanup

To destroy all AWS resources:

```bash
cd terraform
terraform destroy -auto-approve
```

---

## Full Documentation

See [APPLICATION_GUIDE.md](APPLICATION_GUIDE.md) for complete step-by-step instructions.

---

## Components Used

| Component | Version |
|-----------|---------|
| Kubernetes | 1.29 |
| Terraform | 1.6+ |
| Flask | 3.0 |
| Python | 3.11 |
| Ubuntu | 22.04 |

---

**Built for DevOps Course** 🎓
