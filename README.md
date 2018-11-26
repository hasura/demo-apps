# Hasura Demo Apps

This project hosts the configuration required to deploy Hasura demo apps
on a single machine using Docker Compose.

## Architecture

- Docker compose is wrapped in a script called [`dc.sh`](dc.sh) which 
combines multiple yaml config files. 
- Each config file defines an application.
- An application typically contains a GraphQL Engine container and a UI container.
- All GraphQL Engines contact the same Postgres, but different databases.
- Each application's source can be inside the [`repos`](repos) directory as 
submodules.
- When `docker-compose up` (which is wrapped as `./dc.sh up`) is
executed, the docker image for the application is built using the `Dockerfile`
at the root of the source.
- Migrations are mounted and they are applied at start-up
using `cli-migrations` docker image.
- Caddy is used as the web server and each application gets a sub-domain. Let's encrypt issues HTTPS certificates.
- `/v1`, `/v1alpha1` and `/console` are sent to the application's GraphQL Engine.
- Every other path is proxied to the UI.

## Adding a new application

Add the repo source code as a Git submodule inside `repo` directory.

```bash
cd repo
git submodule add <repo-url>
```

The repo should contain:
- A `Dockerfile` at the root.
- `hasura` directory which contains `migrations`.
- Google analytics script in [`ga.html`](ga.html) in the html served.

If the location of `Dockerfile` and `migrations` are different, make sure 
you change the configuration in the compose yaml file.

GrahQL Engine URL for the application will be `/v1alpha1/graphql` -- i.e. on the same hostname. Build the URLs accordingly. Console will be at `/console`. Here is a snippet for reference:

```js
// better suggestions to handle both secure and insecure hosts?
const scheme = (proto) => {
  return window.location.protocol === 'https:' ? `${proto}s` : proto;
}
const HASURA_GRAPHQL_ENGINE_HOSTNAME = window.location.host;
const wsUrl = `${scheme('ws')}://${HASURA_GRAPHQL_ENGINE_HOSTNAME}/v1alpha1/graphql`;
const httpUrl = `${scheme('http')}://${HASURA_GRAPHQL_ENGINE_HOSTNAME}/v1alpha1/graphql`;
const consoleUrl= `${scheme('http')}://${HASURA_GRAPHQL_ENGINE_HOSTNAME}/console`;
```

Create a docker compose yaml file at the root of the repo named as 
the application.

```yaml
# new-application.yaml
version: '3.6'
services:
  new-application-hge:
    image: hasura/graphql-engine:v1.0.0-alpha29.cli-migrations
    depends_on:
    - postgres
    restart: always
    environment:
      HASURA_GRAPHQL_DATABASE_URL: postgres://postgres:@postgres:5432/new_application
      HASURA_GRAPHQL_ENABLE_CONSOLE: "true"
    volumes:
    - ./repos/graphql-engine/community/examples/new-application/hasura/migrations:/hasura-migrations
  new-application-ui:
    restart: always
    image: new-application-ui
    depends_on:
    - new-application-hge
    build: repos/graphql-engine/community/examples/new-application
```

Edit `dc.sh` to add this new file:

```bash
#/bin/bash

docker-compose \
  -f docker-compose.yaml \
  -f realtime-poll.yaml \
  -f realtime-chat.yaml \
  -f realtime-location-tracking.yaml \
  -f react-apollo-todo.yaml \
  -f serverless-push.yaml \
  -f serverless-etl.yaml \
  -f new-application.yaml \
  "$@"
```

Edit `Caddyfile` and replicate an existing block, but change the names:

```
new-application.{$ROOT_DOMAIN} {

    proxy /v1 new-application-hge:8080
    proxy /console new-application-hge:8080
    proxy /v1alpha1 new-application-hge:8080 { websocket }
    proxy / new-application-ui:8080

}
```

Add a link to the app in `index.html`:

```html
    <p><a href="//new-application.{{.Env.ROOT_DOMAIN}}">New Application</a></p>
```

If you need environment variables for the application, create a
`new-application.env.sample` file and add it to `new-application.yaml`.
Refer to [`react-apollo-todo.yaml`](react-apollo-todo.yaml) to see how it's done.


Commit and push the changes.

SSH to the server:

```bash
ssh root@demo.hasura.app
```

Pull the changes:

```bash
cd demo-apps
git pull
```

Update any submodules:

```bash
git submodule sync
git submodule update --init --recursive --remote
```

If there is an env file, make a copy of it and set actual values:

```bash
cp new-application.env.sample new-application.env
vim new-application.env

# ENV_NAME_1=ENV_VALUE_1
```

Update the deployment:

```bash
./dc.sh up -d --build
```

Create a database for the new application:

```bash
./dc.sh exec postgres psql -U postgres -c 'create database new_application;'
```

If everything went well, the new application will be available at `https://new-application.demo.hasura.app`.

## Managing

All `docker-compose` commands should be executed as `./dc.sh`, for example:

List all services:
```bash
./dc.sh ps
```

Logs:
```bash
./dc.sh logs <service-nam>
```

## TODO

- Cron to reset application databases at an interval
- Git push to deploy workflow