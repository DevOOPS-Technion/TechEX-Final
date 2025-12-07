<p align="center">
  <img src="web/assets/TechEX_dark.png" alt="TechEX Logo" width="400" />
</p>

# TechEX - Parcel Management System

**DevOps Final Project** | Kubernetes on AWS with Full CI/CD Automation

---

> ## 📚 [**Complete Setup & User Guide →**](APPLICATION_GUIDE.md)
> 
> For step-by-step deployment instructions, troubleshooting, and detailed usage - see the **[Application Guide](APPLICATION_GUIDE.md)**

---

## Project Info

| Field | Value |
|-------|-------|
| **Name** | Alex Ivanov |
| **GitHub** | [TechEX-Final](https://github.com/DevOOPS-Technion/TechEX-Final) |

---

## Quick Start

```powershell
# 1. Clone & setup
git clone <your-repo-url>
cd TechEX-Final

# 2. Deploy (after configuring GitHub secrets)
git add . && git commit -m "Deploy TechEX" && git push origin main
```

**📖 Need detailed setup?** See the [Application Guide](APPLICATION_GUIDE.md) for:
- Getting AWS Academy credentials
- Configuring GitHub secrets
- Finding the application URL
- Troubleshooting common issues

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
├── APPLICATION_GUIDE.md          # Complete user guide
└── README.md                     # This file
```

---

## Components

| Component | Version |
|-----------|---------|
| Kubernetes | 1.29 |
| Terraform | 1.6+ |
| Flask | 3.0 |
| Python | 3.11 |
| Ubuntu | 22.04 |

---

## API Endpoints

| URL | Description |
|-----|-------------|
| `/` | Home page |
| `/health` | Health check |
| `/parcels` | View all parcels |
| `/add_parcel` | Add new parcel |
| `/statistics` | View statistics |
| `/api/parcels` | JSON API |

---

> ## 📖 [**Full Documentation →**](APPLICATION_GUIDE.md)
> 
> **[Application Guide](APPLICATION_GUIDE.md)** includes:
> - ✅ Prerequisites & setup
> - ✅ AWS Academy credentials guide
> - ✅ GitHub secrets configuration
> - ✅ Deployment walkthrough
> - ✅ Using the application
> - ✅ Troubleshooting guide
> - ✅ Cleanup instructions

---

**Built for DevOps Course** 🎓
