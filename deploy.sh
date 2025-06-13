export COMPOSE_PROJECT_NAME=turboflop
docker-compose build --pull
docker-compose pull
docker-compose down
docker-compose up -d