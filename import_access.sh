#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <windows_path>"
  exit 1
fi

WIN_PATH=$1
LINUX_PATH=$(echo $WIN_PATH | sed 's|\\|/|g' | sed 's|C:|/mnt/c|')

rm -rf msaccess
mkdir msaccess
cp -r $LINUX_PATH/* ./msaccess/

docker exec martes_backend rm -rf /msaccess
docker cp ./msaccess martes_backend:/msaccess
# Execute the import.sh script located in the /app folder of the container
docker exec martes_backend sh -c "cd /app && ./import.sh"


