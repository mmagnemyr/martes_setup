#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <windows_path>"
  exit 1
fi

WIN_PATH=$1
LINUX_PATH=$(echo $WIN_PATH | sed 's|\\|/|g' | sed 's|C:|/mnt/c|')

# rm -rf backup
# mkdir backup
# cp -r $LINUX_PATH/* ./backup/

echo "LINUX_PATH is: $LINUX_PATH"

docker exec martes_mongodb rm -rf /restore_backup3
echo "LINUX_PATH is: $LINUX_PATH"
docker exec -i martes_mongodb mongorestore --username admin --password secret --authenticationDatabase admin --drop --dir /restore_backup3 --nsExclude='admin.*'
