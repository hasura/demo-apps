#/bin/bash

for f in *.yaml; do
  filename="${f%.*}"
  db="${filename//-/_}"
  if [[ "$f" == "docker-compose.yaml" ]]; then
    echo "ignoring docker-compose.yaml"
  else
    echo "deleting and creating database $db"
    docker-compose exec postgres dropdb -U postgres $db
    docker-compose exec postgres createdb -U postgres $db
  fi
done
