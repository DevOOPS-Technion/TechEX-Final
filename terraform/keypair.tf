# ============================================
# SSH Key Pair (Auto-generated)
# ============================================

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-keypair-${random_id.suffix.hex}"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = {
    Name = "${var.project_name}-keypair-${random_id.suffix.hex}"
  }
}

# Save key locally for debugging (optional)
resource "local_file" "ssh_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/techex.pem"
  file_permission = "0600"
}
