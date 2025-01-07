docker exec martes_mongodb rm -rf /backup
docker exec -i martes_mongodb mongodump --username admin --password secret --authenticationDatabase admin --out /backup
docker cp martes_mongodb:/backup ./mongo_backup
