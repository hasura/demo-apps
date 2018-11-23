#/bin/bash

docker-compose exec postgres \
    psql -U postgres -c 'create database realtime_poll;'