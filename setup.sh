#!/bin/bash

CURRENT_DIR="$(pwd)"

# Update package manager
echo "Updating package manager..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt install -y docker.io

# Start and enable Docker service with systemd
echo "Starting Docker service..."
sudo systemctl start docker
echo "Enabling Docker to start on boot..."
sudo systemctl enable docker

# Add the current user to the Docker group
echo "Adding user to the Docker group..."
sudo usermod -aG docker $USER

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
echo "Verifying Docker and Docker Compose installations..."
docker --version
docker-compose --version

# Configure WSL to enable systemd
echo "Configuring WSL to use systemd..."
sudo tee /etc/wsl.conf > /dev/null <<EOL
[boot]
systemd=true
EOL

# Create a systemd service for docker-compose
SERVICE_PATH="/etc/systemd/system/martes-docker-compose.service"
echo "Creating a systemd service for docker-compose at $SERVICE_PATH..."
sudo tee $SERVICE_PATH > /dev/null <<EOL
[Unit]
Description=Start Docker Compose in current directory
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=$CURRENT_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the systemd service
echo "Enabling and starting the Docker Compose service..."
sudo systemctl enable martes-docker-compose.service
sudo systemctl start martes-docker-compose.service

# Final message
echo "Setup complete! Please restart WSL with the following commands:"
echo "1. Exit WSL: exit"
echo "2. In PowerShell: wsl --shutdown"
echo "3. Restart WSL and verify Docker with: docker ps"
echo "4. Verify Docker Compose service with: sudo systemctl status martes-docker-compose.service"
