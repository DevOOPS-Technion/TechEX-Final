# ============================================
# Terraform Outputs
# ============================================

output "load_balancer_dns" {
  description = "Load Balancer DNS - Access your app here!"
  value       = aws_lb.main.dns_name
}

output "app_url" {
  description = "Full application URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "master_public_ip" {
  description = "Master node public IP"
  value       = aws_instance.master.public_ip
}

output "master_private_ip" {
  description = "Master node private IP"
  value       = aws_instance.master.private_ip
}

output "worker1_public_ip" {
  description = "Worker 1 public IP"
  value       = aws_instance.worker1.public_ip
}

output "worker2_public_ip" {
  description = "Worker 2 public IP"
  value       = aws_instance.worker2.public_ip
}

output "ssh_key" {
  description = "SSH private key (sensitive)"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

output "ssh_to_master" {
  description = "SSH command for master"
  value       = "ssh -i techex.pem ubuntu@${aws_instance.master.public_ip}"
}
