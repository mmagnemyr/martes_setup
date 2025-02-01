#!/bin/bash
# This script updates /etc/wsl.conf to ensure that:
# 1. The [network] section contains "localhostForwarding=true"
# 2. The [user] section is set to use the specified default user

# Set your desired default user here:
DEFAULT_USER="root"

CONF_FILE="/etc/wsl.conf"

# Create the file if it doesn't exist
if [ ! -f "$CONF_FILE" ]; then
  echo "Creating $CONF_FILE..."
  sudo touch "$CONF_FILE"
fi

# Function to add the network section if missing
add_network_section() {
  echo -e "\n[network]\nlocalhostForwarding=true" | sudo tee -a "$CONF_FILE" > /dev/null
  echo "Added [network] section with localhostForwarding=true."
}

# Update or add the [network] section
if grep -q "^\[network\]" "$CONF_FILE"; then
  if grep -q "localhostForwarding" "$CONF_FILE"; then
    echo "localhostForwarding is already set in /etc/wsl.conf."
  else
    echo "Appending localhostForwarding=true under the existing [network] section..."
    sudo sed -i '/^\[network\]/a localhostForwarding=true' "$CONF_FILE"
  fi
else
  echo "[network] section not found. Adding section with localhostForwarding=true..."
  add_network_section
fi

# Function to add or update the [user] section with the default user
update_user_section() {
  # If [user] section exists, update or append the default setting
  if grep -q "^\[user\]" "$CONF_FILE"; then
    # Check if a default directive already exists in the [user] section
    if grep -q "^\s*default\s*=" "$CONF_FILE"; then
      echo "Updating default user in the existing [user] section..."
      sudo sed -i "s/^\s*default\s*=.*/default=${DEFAULT_USER}/" "$CONF_FILE"
    else
      echo "Appending default=${DEFAULT_USER} under the existing [user] section..."
      sudo sed -i "/^\[user\]/a default=${DEFAULT_USER}" "$CONF_FILE"
    fi
  else
    # If the [user] section doesn't exist, append it at the end of the file.
    echo "Adding [user] section with default=${DEFAULT_USER}..."
    echo -e "\n[user]\ndefault=${DEFAULT_USER}" | sudo tee -a "$CONF_FILE" > /dev/null
  fi
}

# Update or add the [user] section
update_user_section

echo ""
echo "Updated /etc/wsl.conf content:"
cat "$CONF_FILE"

echo ""
echo "Note: For changes to take effect, please shutdown WSL using:"
echo "  wsl --shutdown"
echo "Then restart your WSL distribution."
