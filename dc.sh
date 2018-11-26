#/bin/bash

docker-compose \
  -f docker-compose.yaml \
  -f realtime-poll.yaml \
  -f realtime-location-tracking.yaml \
  -f react-apollo-todo.yaml \
  -f serverless-push.yaml \
  "$@"