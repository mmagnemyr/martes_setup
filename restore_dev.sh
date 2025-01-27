#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <windows_path>"
  exit 1
fi

WIN_PATH=$1
LINUX_PATH=$(echo $WIN_PATH | sed 's|\\|/|g' | sed 's|C:|/mnt/c|')


echo "Restoring backup in : $LINUX_PATH/backup"

docker exec martes_mongodb_dev rm -rf /restore_backup
docker cp  $LINUX_PATH/backup martes_mongodb_dev:/restore_backup
docker exec -i martes_mongodb_dev mongorestore --username admin --password secret --authenticationDatabase admin --drop --dir /restore_backup --nsExclude='admin.*'
