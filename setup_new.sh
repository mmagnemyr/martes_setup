#!/bin/bash

CURRENT_DIR="$(pwd)"

echo "Updating package list and upgrading existing packages..."
sudo apt-get update && sudo apt-get upgrade -y

#
# 1. Set up Docker’s official apt repository
#
echo "Installing prerequisites for Docker’s official repository..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "Adding Docker’s official GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "Setting up the Docker stable repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package list after adding Docker’s repo..."
sudo apt-get update

#
# 2. Install Docker Engine + Docker Compose plugin
#
echo "Installing Docker Engine, CLI, containerd, Buildx, and Docker Compose plugin..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

#
# 3. Start & Enable Docker
#
echo "Starting and enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

#
# 4. Add current user to the Docker group
#
echo "Adding user '$USER' to the docker group (so you can run Docker without sudo)..."
sudo usermod -aG docker "$USER"

#
# 5. Verify Docker & Docker Compose
#
echo "Verifying Docker version..."
docker --version

echo "Verifying Docker Compose plugin version..."
docker compose version

#
# 6. Configure WSL to enable systemd
#
echo "Configuring WSL to enable systemd..."
sudo tee /etc/wsl.conf > /dev/null <<EOL
[boot]
systemd=true
EOL

#
# 7. Create a systemd service for your Compose project in $CURRENT_DIR
#
SERVICE_PATH="/etc/systemd/system/martes-docker-compose.service"
echo "Creating a systemd service for docker compose at $SERVICE_PATH..."
sudo tee "$SERVICE_PATH" > /dev/null <<EOL
[Unit]
Description=Start Docker Compose in current directory
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=$CURRENT_DIR
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL

echo "Enabling and starting the Docker Compose systemd service..."
sudo systemctl enable martes-docker-compose.service
sudo systemctl start martes-docker-compose.service

#
# 8. Final Messages
#
# echo "=========================================================="
# echo "Docker + Docker Compose setup complete!"
# echo
# echo "1. **Close** this WSL/terminal session completely."
# echo "2. In PowerShell or CMD, run:  wsl --shutdown"
# echo "3. Re-open WSL, then verify Docker with:  docker ps"
# echo "   and Docker Compose with:  docker compose ls"
# echo "4. Check the Compose service status with:  systemctl status martes-docker-compose.service"
# echo "=========================================================="
