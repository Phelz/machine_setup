#!/bin/bash

# Step 1: Update the package index
echo "Updating package index..."
sudo apt update

# Step 2: Install required dependencies
echo "Installing required dependencies..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Step 3: Add Docker’s official GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Step 4: Add Docker’s stable repository
echo "Adding Docker repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Step 5: Update the package index again after adding Docker repository
echo "Updating package index again..."
sudo apt update

# Step 6: Install Docker
echo "Installing Docker..."
sudo apt install -y docker-ce

# Step 7: Verify Docker installation
echo "Verifying Docker installation..."
sudo systemctl status docker --no-pager

# Step 8: Optional - Add your user to the Docker group (requires relog)
echo "Adding user to Docker group..."
sudo usermod -aG docker $USER
echo "You need to log out and log back in for this to take effect."

# Step 9: Optional - Install Docker Compose (if desired)
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Step 10: Make Docker Compose executable
echo "Making Docker Compose executable..."
sudo chmod +x /usr/local/bin/docker-compose

# Step 11: Verify Docker Compose installation
echo "Verifying Docker Compose installation..."
docker-compose --version

# Step 12: Pull the Docker image for Anaconda
echo "Pulling Docker image for Anaconda..."
docker pull ghcr.io/andrewrothstein/ansible-anaconda:0.0.0-fedora.39

# Step 13: Verify the Docker image has been pulled
echo "Verifying Docker image..."
docker images

echo "Docker installation and Anaconda image pull completed!"
