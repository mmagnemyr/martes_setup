# turn off the running containers
docker compose down

# pull updates
docker compose pull

# start conntainers
docker compose up -d

# remove any unused containers
docker image prune -f

