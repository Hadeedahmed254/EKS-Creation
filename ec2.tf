


############################
# SonarQube Node
############################

resource "aws_instance" "sonar" {
  ami                         = "ami-0ecb62995f68bb549"
  instance_type               = "m7i-flex.large"
  subnet_id                   = aws_subnet.cicd_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.cicd_sga.id]
  key_name                    = "django"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash
set -eux

echo "🔹 Updating package manager..."
apt-get update -y

echo "🔹 Installing dependencies..."
apt-get install -y ca-certificates curl

echo "🔹 Creating directory for Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings

echo "🔹 Downloading Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "🔹 Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔹 Updating package manager again..."
apt-get update -y

echo "🔹 Installing Docker Engine and plugins..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "🔹 Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

echo "🔹 Setting Docker socket permissions for all users..."
chmod 666 /var/run/docker.sock

echo "✅ Docker installation complete"
EOF

  tags = {
    Name = "Sonar-qube"
  }
}

############################
# Nexus Node
############################

resource "aws_instance" "nexus" {
  ami                         = "ami-0ecb62995f68bb549"
  instance_type               = "m7i-flex.large"
  subnet_id                   = aws_subnet.cicd_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.cicd_sga.id]
  key_name                    = "django"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash
set -eux

echo "🔹 Updating package manager..."
apt-get update -y

echo "🔹 Installing dependencies..."
apt-get install -y ca-certificates curl

echo "🔹 Creating directory for Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings

echo "🔹 Downloading Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "🔹 Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔹 Updating package manager again..."
apt-get update -y

echo "🔹 Installing Docker Engine and plugins..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "🔹 Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

echo "🔹 Setting Docker socket permissions for all users..."
chmod 666 /var/run/docker.sock

echo "✅ Docker installation complete"
EOF

  tags = {
    Name = "Nexus"
  }
}







############################
# Jenkins Node
############################

resource "aws_instance" "jenkins" {
  ami                         = "ami-0ecb62995f68bb549"
  instance_type               = "m7i-flex.large"
  subnet_id                   = aws_subnet.cicd_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.cicd_sga.id]
  key_name                    = "django"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

user_data = <<-EOF
#!/bin/bash
set -eux

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data ) 2>&1

echo "🔹 Updating system..."
apt-get update -y
apt-get upgrade -y

echo "🔹 Installing base dependencies..."
apt-get install -y ca-certificates curl gnupg lsb-release

############################
# Docker Installation
############################
echo "🔹 Installing Docker..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
> /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

############################
# Jenkins Installation
############################
echo "🔹 Installing Java 17..."
apt-get install -y openjdk-17-jdk

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

apt-get update -y
apt-get install -y jenkins

systemctl enable jenkins
systemctl start jenkins

############################
# Docker access for Jenkins
############################
echo "🔹 Allowing Jenkins to use Docker..."
usermod -aG docker jenkins

systemctl restart jenkins

# Update system
apt-get update -y

# Install dependencies
apt-get install -y curl gnupg lsb-release

# Create keyrings directory
install -m 0755 -d /etc/apt/keyrings

# Add Trivy GPG key
curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key | tee \
  /etc/apt/keyrings/trivy.asc > /dev/null

chmod a+r /etc/apt/keyrings/trivy.asc

# Add Trivy repository
echo "deb [signed-by=/etc/apt/keyrings/trivy.asc] \
https://aquasecurity.github.io/trivy-repo/deb \
$(lsb_release -cs) main" \
> /etc/apt/sources.list.d/trivy.list

# Install Trivy
apt-get update -y
apt-get install -y trivy

echo "Updating system..."
apt update -y

echo "Installing required packages..."
apt install -y apt-transport-https ca-certificates curl gnupg

echo "Adding Kubernetes GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "Adding Kubernetes repository..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

echo "Installing kubectl..."
apt update -y
apt install -y kubectl

echo "kubectl installation completed"
kubectl version --client || true
EOF


  tags = {
    Name = "Jenkins"
  }
}





resource "aws_eip" "sonar_eip" {
  instance = aws_instance.sonar.id
  domain   = "vpc"
  tags     = { Name = "Sonar-EIP" }
}



resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"
  tags     = { Name = "Jenkins-EIP" }
}



