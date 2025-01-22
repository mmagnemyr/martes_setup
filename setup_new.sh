#!/bin/bash

CURRENT_DIR="$(pwd)"
CURRENT_USER=$(whoami)
MARTES_USER="martes"

echo "Current user: $CURRENT_USER"
echo "Ensuring both Docker and 'martes' permissions are configured..."

#
# 1. Update packages and install Docker
#
echo "Updating package list and upgrading existing packages..."
sudo apt-get update && sudo apt-get upgrade -y

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

echo "Installing Docker Engine and Docker Compose plugin..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "Starting and enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

#
# 2. Add current user to the Docker group
#
echo "Adding user '$CURRENT_USER' to the docker group..."
sudo groupadd docker || echo "Docker group already exists."
sudo usermod -aG docker "$CURRENT_USER"

# Fix Docker socket permissions
echo "Fixing Docker socket permissions..."
if [ -S /var/run/docker.sock ]; then
    sudo chown root:docker /var/run/docker.sock
    sudo chmod 660 /var/run/docker.sock
fi

#
# 3. Create the 'martes' user
#
echo "Creating the 'martes' user..."
if id -u $MARTES_USER &>/dev/null; then
    echo "User 'martes' already exists."
else
    sudo adduser --disabled-password --gecos "" $MARTES_USER
    echo "User 'martes' created."
fi

#
# 4. Grant full access to 'martes' for the current user
#
MARTES_HOME="/home/$MARTES_USER"

echo "Granting full access to '$MARTES_HOME' for user '$CURRENT_USER'..."
sudo usermod -aG $CURRENT_USER $MARTES_USER  # Add the current user to the 'martes' user's group
sudo chmod -R 770 $MARTES_HOME              # Set full permissions for the owner and group
sudo setfacl -R -m u:$CURRENT_USER:rwx $MARTES_HOME # Add ACL to ensure access for current user
sudo setfacl -R -d -m u:$CURRENT_USER:rwx $MARTES_HOME # Set default ACL for new files

#
# 5. Configure WSL for systemd
#
echo "Configuring WSL to enable systemd..."
sudo tee /etc/wsl.conf > /dev/null <<EOL
[boot]
systemd=true
EOL

#
# 6. Create a systemd service for Docker Compose in the current directory
#
SERVICE_PATH="/etc/systemd/system/martes-docker-compose.service"
echo "Creating a systemd service for Docker Compose at $SERVICE_PATH..."
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
# 7. Final Messages
#
echo "=========================================================="
echo "Setup complete!"
echo "Docker and 'martes' permissions configured."
echo "1. Restart WSL: wsl --shutdown"
echo "2. Open WSL and test 'docker ps'."
echo "=========================================================="
