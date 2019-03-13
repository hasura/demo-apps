#/bin/bash

docker-compose \
  -f docker-compose.yaml \
  -f realtime-poll.yaml \
  -f realtime-chat.yaml \
  -f realtime-location-tracking.yaml \
  -f react-apollo-todo.yaml \
  -f serverless-push.yaml \
  -f serverless-etl.yaml \
  -f do-blog-learn-graphql-by-doing.yaml \
  -f whatsapp-clone.yaml \
  "$@"
