# restore dev
docker exec martes_mongodb_dev rm -rf /backup
docker cp ./backup martes_mongodb_dev:/restore_backup3
docker exec -i martes_mongodb_dev mongorestore   --username admin   --password secret   --authenticationDatabase admin   --drop   --dir /restore_backup3
