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


## git commands
if you want to remove a folder that you accidently added and commited (in this case the folder backup)
git rm -r --cached backup
