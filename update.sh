git pull

# turn off the running containers
docker compose -f docker-compose.yaml.old down

# pull updates
docker compose pull

# start conntainers
docker compose up -d

# remove any unused containers
docker image prune -f

