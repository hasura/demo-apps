#/bin/bash

# stop all containers

./dc.sh down && docker-compose up -d && ./create_databases.sh && ./dc.sh up -d
