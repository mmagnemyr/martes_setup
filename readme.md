## martes setup

## att göra script exekverbara
chmod +x copy_from_win.sh
chmod +x docker_mongo_restore.sh
chmod +x docker_mongo_backup.sh


## backup
./docker_mongo_backup.sh


## docker commands
-stop all containers

docker stop $(docker ps -q)
