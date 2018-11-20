#/bin/bash

docker-compose \
  -f docker-compose.yaml \
  -f realtime-poll.yaml \
  "$@"