#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <windows_path>"
  exit 1
fi

WIN_PATH=$1
LINUX_PATH=$(echo $WIN_PATH | sed 's|\\|/|g' | sed 's|C:|/mnt/c|')

# Debug: Print the paths
echo "WIN_PATH: $WIN_PATH"
echo "LINUX_PATH: $LINUX_PATH"

# rm -rf msaccess
mkdir msaccess

# Debug: Check if the LINUX_PATH exists
if [ ! -d "$LINUX_PATH" ]; then
  echo "Error: Directory $LINUX_PATH does not exist."
  exit 1
fi

# Debug: List the contents of the LINUX_PATH
echo "Contents of $LINUX_PATH:"
ls -la "$LINUX_PATH"

cp -r "$LINUX_PATH"/* ./msaccess/

docker exec martes_backend rm -rf /msaccess
docker cp ./msaccess martes_backend:/msaccess
# Execute the import.sh script located in the /app folder of the container
docker exec martes_backend sh -c "cd /app && ./import.sh"