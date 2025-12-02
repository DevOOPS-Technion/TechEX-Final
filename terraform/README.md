# Terraform Infrastructure

AWS infrastructure for TechEX Kubernetes cluster.

## Resources Created

| Resource | Description |
|----------|-------------|
| VPC | `10.0.0.0/16` with 2 public subnets |
| EC2 (x3) | Master + 2 Workers (t3.medium) |
| ALB | Application Load Balancer on port 80 |
| Security Groups | For ALB and K8s nodes |
| SSH Key Pair | Auto-generated |

## File Structure

| File | Purpose |
|------|---------|
| `provider.tf` | AWS provider config |
| `variables.tf` | Input variables |
| `network.tf` | VPC, subnets, routing |
| `sg.tf` | Security groups |
| `keypair.tf` | SSH key generation |
| `ec2.tf` | EC2 instances |
| `alb.tf` | Load balancer |
| `outputs.tf` | Output values |
| `scripts/` | EC2 bootstrap scripts |

## Usage

The CI/CD pipeline handles this automatically. For manual use:

```bash
terraform init
terraform apply -var="docker_image=youruser/techex"
```

## Outputs

After apply:
- `app_url` - Application URL
- `master_public_ip` - SSH to master
- `ssh_key` - Private key (sensitive)
