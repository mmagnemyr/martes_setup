docker exec martes_mongodb rm -rf /backup
docker cp ./backup martes_mongodb:/restore_backup3
docker exec -i martes_mongodb mongorestore   --username admin   --password secret   --authenticationDatabase admin   --drop   --dir /restore_backup3

