#!/usr/bin/env bash

# This script uninstalls Docker Engine + Docker Compose plugin
# and removes associated systemd services and config files.

echo "=== Stopping and disabling the martes-docker-compose systemd service ==="
sudo systemctl stop martes-docker-compose.service 2>/dev/null || true
sudo systemctl disable martes-docker-compose.service 2>/dev/null || true

SERVICE_PATH="/etc/systemd/system/martes-docker-compose.service"
if [ -f "$SERVICE_PATH" ]; then
  echo "Removing systemd service file at $SERVICE_PATH..."
  sudo rm -f "$SERVICE_PATH"
fi

# Reload systemd to finalize removal
sudo systemctl daemon-reload

echo "=== Removing Docker packages (docker-ce, docker-ce-cli, containerd.io, etc.) ==="
# Remove all Docker packages
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Also remove docker.io if it was previously installed
sudo apt-get purge -y docker.io

echo "=== Removing leftover Docker data (images, containers, volumes) ==="
# WARNING: This removes *all* Docker data (images, containers, volumes).
# If you want to keep them, comment this out.
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

echo "=== Removing Docker’s official repository and GPG key ==="
# Remove Docker’s apt repo list
sudo rm -f /etc/apt/sources.list.d/docker.list

# Remove Docker’s GPG keyring
sudo rm -f /etc/apt/keyrings/docker.gpg

echo "=== Updating package lists after removing Docker’s repo ==="
sudo apt-get update

# Optionally remove the user from the docker group
# (comment out if you want to stay in the group)
# echo "Removing $USER from the docker group..."
# sudo deluser $USER docker

# If you want to revert the WSL systemd setting entirely:
# This removes the entire /etc/wsl.conf file (if you only used it for systemd=true).
# If you have *other* WSL configuration in wsl.conf, consider editing it manually.
echo "=== Reverting /etc/wsl.conf (removing systemd=true) ==="
if [ -f /etc/wsl.conf ]; then
  sudo rm /etc/wsl.conf
fi

echo "=== Uninstall complete. ==="
echo "If you're in WSL, run 'wsl --shutdown' in Windows to ensure a full refresh."
echo "Docker has been removed, including Docker Compose plugin and systemd services."
