Setup Sharedlists with Docker
=============================

[![Docker Status](https://img.shields.io/docker/build/foodcoops/sharedlists.svg)](https://hub.docker.com/r/foodcoops/sharedlists)

## Development Setup

1. Copy `config/database.yml.SAMPLE` to `config/database.yml` and run:
    ```
    docker-compose run --rm app bundle
    docker-compose run --rm app rails db:setup
    ```
1. Run `docker-compose`:
   ```
   docker-compose up
   ```
1. Open your favorite browser and open the web browser at http://localhost:3000/
1. Login using the default credentials: `admin@example.com/secret`


## Production Setup

1.  Either fetch the image, or build it:
    ```
    docker pull sharedlists:latest
    ```
    or
    ```
    docker build --tag sharedlists:latest --rm
    ```
1. Then set environment variables `SECRET_KEY_BASE` and `DATABASE_URL` and run:
    ```
    docker run --name sharedlists_web \
      -e SECRET_KEY_BASE -e DATABASE_URL -e RAILS_FORCE_SSL=false \
      sharedlists:latest
    ```
1. To run cronjobs, start another instance:
   ```
    docker run --name sharedlists_cron \
      -e SECRET_KEY_BASE -e DATABASE_URL \
      sharedlists:latest  ./proc-start cron
    ```
1. If you want to process incoming mails, add another instance like the previous,
substituting `mail` for `cron`.
