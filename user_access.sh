CURRENT_DIR="$(pwd)"
CURRENT_USER=$(whoami)
MARTES_USER="martes"

sudo apt-get update
sudo apt-get install -y acl


echo "Adding user '$CURRENT_USER' to the docker group..."
sudo groupadd docker || echo "Docker group already exists."
sudo usermod -aG docker "$CURRENT_USER"

# Fix Docker socket permissions
echo "Fixing Docker socket permissions..."
if [ -S /var/run/docker.sock ]; then
    sudo chown root:docker /var/run/docker.sock
    sudo chmod 660 /var/run/docker.sock
fi

MARTES_HOME="/home/$MARTES_USER"

echo "Granting full access to '$MARTES_HOME' for user '$CURRENT_USER'..."
sudo usermod -aG $CURRENT_USER $MARTES_USER  # Add the current user to the 'martes' user's group
sudo chmod -R 770 $MARTES_HOME              # Set full permissions for the owner and group
sudo setfacl -R -m u:$CURRENT_USER:rwx $MARTES_HOME # Add ACL to ensure access for current user
sudo setfacl -R -d -m u:$CURRENT_USER:rwx $MARTES_HOME # Set default ACL for new files

