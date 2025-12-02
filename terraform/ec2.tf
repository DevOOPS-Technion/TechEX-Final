# ============================================
# EC2 Instances - Kubernetes Cluster
# ============================================

# Master Node (Control Plane + NFS)
resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.k8s.id]
  private_ip             = "10.0.1.10"

  user_data = base64encode(templatefile("${path.module}/scripts/user-data-control-plane.sh", {
    docker_image     = var.docker_image
    control_plane_ip = "10.0.1.10"
    worker_1_ip      = "10.0.1.11"
    worker_2_ip      = "10.0.2.11"
    pod_cidr         = "10.244.0.0/16"
  }))

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-master"
    Role = "master"
  }

  depends_on = [aws_internet_gateway.main]
}

# Worker 1
resource "aws_instance" "worker1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.k8s.id]
  private_ip             = "10.0.1.11"

  user_data = base64encode(templatefile("${path.module}/scripts/user-data-worker.sh", {
    control_plane_ip = "10.0.1.10"
  }))

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-worker-1"
    Role = "worker"
  }

  depends_on = [aws_instance.master]
}

# Worker 2
resource "aws_instance" "worker2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = aws_subnet.public_2.id
  vpc_security_group_ids = [aws_security_group.k8s.id]
  private_ip             = "10.0.2.11"

  user_data = base64encode(templatefile("${path.module}/scripts/user-data-worker.sh", {
    control_plane_ip = "10.0.1.10"
  }))

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-worker-2"
    Role = "worker"
  }

  depends_on = [aws_instance.master]
}
