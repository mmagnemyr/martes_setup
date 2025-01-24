#!/bin/bash
# setup_wsl.sh
# This script configures WSL to use systemd and sets up the keepwsl service.

set -e

# Function to check if the script is run as root
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "Please run as root (use sudo)." >&2
        exit 1
    fi
}

# Function to enable systemd in /etc/wsl.conf
enable_systemd() {
    echo "Configuring /etc/wsl.conf to enable systemd..."
    cat <<EOF | sudo tee /etc/wsl.conf > /dev/null
[boot]
systemd=true

[automount]
enabled=true
EOF
    echo "/etc/wsl.conf configured successfully."
}

# Function to create the keepwsl.service file
create_keepwsl_service() {
    echo "Creating keepwsl.service..."
    cat <<EOF | sudo tee /etc/systemd/system/keepwsl.service > /dev/null
[Unit]
Description=Keep WSL Running
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/tail -f /dev/null
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF
    echo "keepwsl.service created successfully."
}

# Function to enable and start the keepwsl service
enable_and_start_service() {
    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload

    echo "Enabling keepwsl service to start on boot..."
    sudo systemctl enable keepwsl

    echo "Starting keepwsl service..."
    sudo systemctl start keepwsl

    echo "Verifying keepwsl service status..."
    sudo systemctl is-active --quiet keepwsl && echo "keepwsl service is active." || { echo "keepwsl service failed to start." >&2; exit 1; }
}

# Execute functions
check_root
enable_systemd
create_keepwsl_service
enable_and_start_service

echo "WSL configuration with systemd and keepwsl service completed successfully."
