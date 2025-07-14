#!/bin/bash

set -e

echo "----------------------------"
echo "Installing Docker Engine..."
echo "----------------------------"

# Remove old Docker versions
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# Update apt and install required packages
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Add Docker’s official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Create docker group and add user
sudo groupadd docker || true
sudo usermod -aG docker "$USER"

echo "Note: You may need to log out and log back in for the docker group changes to take effect."

echo "----------------------"
echo "Installing nektos/act..."
echo "----------------------"

# Detect latest act version
ACT_LATEST=$(curl -s https://api.github.com/repos/nektos/act/releases/latest | grep "tag_name" | cut -d '"' -f 4)

# Download binary
curl -sL "https://github.com/nektos/act/releases/download/${ACT_LATEST}/act_$(uname -s)_$(uname -m).tar.gz" -o act.tar.gz

# Extract and install
mkdir -p act-install
tar -xzf act.tar.gz -C act-install
sudo mv act-install/act /usr/local/bin/
rm -rf act.tar.gz act-install

# Verify installation
echo
echo "✅ Installation complete!"
echo "Docker version: $(docker --version)"
echo "act version: $(act --version)"
