Setup Sharedlists with Docker
=============================

[![Docker Status](https://img.shields.io/docker/build/foodcoops/sharedlists.svg)](https://hub.docker.com/r/foodcoops/sharedlists)

## Development Setup

1. Copy `config/database.yml.SAMPLE` to `config/database.yml` and run:
    ```
    docker-compose -f docker-compose-dev.yml run --rm app bundle
    docker-compose -f docker-compose-dev.yml run --rm app rails db:setup
    ```
1. Run `docker-compose`:
   ```
   docker-compose -f docker-compose-dev.yml up
   ```
1. Open your favorite browser and open the web browser at http://localhost:3000/
1. Login using the default credentials: `admin@example.com/secret`


## Production Setup

1.  Create an `.env` file and define some variables:
    ```
    SHAREDLISTS_DB_PASSWORD=
    SHAREDLISTS_SECRET_KEY_BASE=
    MAILER_DOMAIN=
    MARIADB_ROOT_PASSWORD=
    ```
1. Run `docker-compose`:
    ```
    docker-compose up -d
    ```
