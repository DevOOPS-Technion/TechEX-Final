# ============================================
# TechEX Deployment Script for Windows
# ============================================
# Configured for AWS Academy (uses session token)

param(
    [switch]$SetupSecrets,
    [switch]$LocalTest,
    [switch]$Cleanup
)

$ErrorActionPreference = "Stop"

Write-Host @"

  _____         _     _____ __  __
 |_   _|__  ___| |__ | ____|\ \/ /
   | |/ _ \/ __| '_ \|  _|   \  / 
   | |  __/ (__| | | | |___  /  \ 
   |_|\___|\___|_| |_|_____|/_/\_\
                                  
   Parcel Management System - DevOps Deployment
   
"@ -ForegroundColor Cyan

# Check prerequisites
function Test-Prerequisites {
    Write-Host "`n[*] Checking prerequisites..." -ForegroundColor Yellow
    
    $missing = @()
    
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        $missing += "Git (https://git-scm.com/)"
    }
    
    if ($missing.Count -gt 0) {
        Write-Host "`n[!] Missing tools:" -ForegroundColor Red
        $missing | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
        exit 1
    }
    
    Write-Host "[+] All prerequisites installed!" -ForegroundColor Green
}

# Setup GitHub Secrets interactively
function Set-GitHubSecrets {
    Write-Host "`n[*] GitHub Secrets Setup for AWS Academy" -ForegroundColor Yellow
    Write-Host "=========================================`n" -ForegroundColor White
    
    Write-Host "You need to configure these secrets in your GitHub repository:" -ForegroundColor White
    Write-Host "Repository -> Settings -> Secrets and variables -> Actions`n" -ForegroundColor Gray
    
    Write-Host "Required Secrets (5 total):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "From AWS Academy (Learner Lab -> AWS Details -> Show):" -ForegroundColor Yellow
    Write-Host "  1. AWS_ACCESS_KEY_ID     - Starts with ASIA..." -ForegroundColor White
    Write-Host "  2. AWS_SECRET_ACCESS_KEY - Long secret key" -ForegroundColor White
    Write-Host "  3. AWS_SESSION_TOKEN     - Very long token (required!)" -ForegroundColor White
    Write-Host ""
    Write-Host "From Docker Hub (Account Settings -> Security):" -ForegroundColor Yellow
    Write-Host "  4. DOCKERHUB_USERNAME    - Your Docker Hub username" -ForegroundColor White
    Write-Host "  5. DOCKERHUB_TOKEN       - Access token from Docker Hub" -ForegroundColor White
    
    Write-Host "`n[*] Creating secrets template file..." -ForegroundColor Yellow
    
    $secretsTemplate = @"
# ============================================
# TechEX GitHub Secrets Template
# ============================================
# Copy these values to GitHub -> Settings -> Secrets -> Actions
# DO NOT COMMIT THIS FILE!

# From AWS Academy (Learner Lab -> AWS Details -> Show):
AWS_ACCESS_KEY_ID=ASIA...
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_SESSION_TOKEN=your-very-long-session-token

# From Docker Hub:
DOCKERHUB_USERNAME=your-dockerhub-username
DOCKERHUB_TOKEN=your-access-token

# ============================================
# IMPORTANT: AWS Academy credentials expire every ~4 hours!
# Update the 3 AWS secrets before each deployment.
# ============================================
"@
    
    $secretsTemplate | Out-File -FilePath "SECRETS_TEMPLATE.txt" -Encoding UTF8
    
    # Add to gitignore if not present
    $gitignore = Get-Content ".gitignore" -ErrorAction SilentlyContinue
    if ($gitignore -notcontains "SECRETS_TEMPLATE.txt") {
        Add-Content -Path ".gitignore" -Value "`nSECRETS_TEMPLATE.txt"
    }
    
    Write-Host "[+] Created SECRETS_TEMPLATE.txt" -ForegroundColor Green
    Write-Host "[!] This file is gitignored - safe to fill in values" -ForegroundColor Yellow
    
    Write-Host "`n" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "1. Go to AWS Academy -> Learner Lab" -ForegroundColor White
    Write-Host "2. Click 'Start Lab' if not already started" -ForegroundColor White
    Write-Host "3. Click 'AWS Details' -> 'Show'" -ForegroundColor White
    Write-Host "4. Copy the 3 AWS credentials" -ForegroundColor White
    Write-Host "5. Go to GitHub repo -> Settings -> Secrets -> Actions" -ForegroundColor White
    Write-Host "6. Add all 5 secrets" -ForegroundColor White
    Write-Host "7. Run: git add . && git commit -m 'Deploy' && git push" -ForegroundColor White
    Write-Host "============================================" -ForegroundColor Cyan
}

# Test Docker build locally
function Test-LocalBuild {
    Write-Host "`n[*] Building Docker image locally..." -ForegroundColor Yellow
    
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "[!] Docker not installed. Skipping local test." -ForegroundColor Yellow
        return
    }
    
    docker build -f docker/Dockerfile -t techex:local .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[+] Docker build successful!" -ForegroundColor Green
        
        Write-Host "[*] Starting container for local test..." -ForegroundColor Yellow
        docker run -d --name techex-test -p 5000:5000 techex:local
        
        Start-Sleep -Seconds 10
        
        Write-Host "[+] Access at: http://localhost:5000" -ForegroundColor Cyan
        
        Write-Host "`nPress Enter to stop the test container..." -ForegroundColor Gray
        Read-Host
        
        docker stop techex-test
        docker rm techex-test
    }
}

# Cleanup
function Invoke-Cleanup {
    Write-Host "`n[*] Cleanup" -ForegroundColor Yellow
    Write-Host "To destroy AWS resources, run:" -ForegroundColor White
    Write-Host "  cd terraform" -ForegroundColor Cyan
    Write-Host "  terraform destroy -auto-approve" -ForegroundColor Cyan
}

# Main
Test-Prerequisites

if ($SetupSecrets) {
    Set-GitHubSecrets
} elseif ($LocalTest) {
    Test-LocalBuild
} elseif ($Cleanup) {
    Invoke-Cleanup
} else {
    Write-Host "`nUsage:" -ForegroundColor Cyan
    Write-Host "  .\deploy.ps1 -SetupSecrets  # Show secrets setup guide" -ForegroundColor White
    Write-Host "  .\deploy.ps1 -LocalTest     # Test Docker build locally" -ForegroundColor White  
    Write-Host "  .\deploy.ps1 -Cleanup       # Show cleanup instructions" -ForegroundColor White
    
    Write-Host "`nQuick Deploy:" -ForegroundColor Yellow
    Write-Host "  1. .\deploy.ps1 -SetupSecrets" -ForegroundColor White
    Write-Host "  2. Add 5 secrets to GitHub" -ForegroundColor White
    Write-Host "  3. git add . && git commit -m 'Deploy' && git push" -ForegroundColor White
    Write-Host "  4. Wait ~15 min, get URL from GitHub Actions" -ForegroundColor White
}

Write-Host "`n" -ForegroundColor White
