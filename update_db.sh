# Execute the import.sh script located in the /app folder of the container
docker exec martes_backend sh -c "cd /app && python ./macli.py -action init -lk system"