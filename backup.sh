#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <windows_path>"
  exit 1
fi

WIN_PATH=$1
LINUX_PATH=$(echo $WIN_PATH | sed 's|\\|/|g' | sed 's|C:|/mnt/c|')

rm -rf backup
mkdir backup
cp -r $LINUX_PATH/* ./backup/


docker exec martes_mongodb rm -rf /backup
docker exec -i martes_mongodb mongodump --username admin --password secret --authenticationDatabase admin --out /backup
docker cp martes_mongodb:/backup ./mongo_backup

# Copy the backup to the Windows path + /backup
WIN_BACKUP_PATH=$(echo $WIN_PATH | sed 's|\\|/|g' | sed 's|C:|/mnt/c|')
mkdir -p $WIN_BACKUP_PATH
cp -r ./mongo_backup/* $WIN_BACKUP_PATH/