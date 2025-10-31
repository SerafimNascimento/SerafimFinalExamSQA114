#!/bin/bash
set -e

echo "=== [1/5] Updating system ==="
dnf -y update

echo "=== [2/5] Installing base tools ==="
dnf -y install java-21-amazon-corretto git nodejs npm curl wget

echo "=== [3/5] Adding Jenkins repository ==="
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo "=== [4/5] Installing Jenkins ==="
dnf -y install jenkins

echo "=== [5/5] Enabling and starting Jenkins ==="
systemctl enable jenkins
systemctl start jenkins

# Get public IP of this instance
PUBIP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "<public-ip>")

echo "===================================================="
echo "Jenkins is ready at: http://$PUBIP:8080"
echo "For the first login, get the password from:"
echo "  /var/lib/jenkins/secrets/initialAdminPassword"
echo "===================================================="
