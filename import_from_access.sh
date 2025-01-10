  GNU nano 6.2                                                               import_from_access.sh                                                                        
docker exec martes_backend rm -rf /msaccess
docker cp ./msaccess martes_backend:/msaccess
# Execute the import.sh script located in the /app folder of the container
docker exec martes_backend sh -c "cd /app && ./import.sh"
