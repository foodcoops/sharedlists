# Sharedlists

Sharedlists is a simple rails driven database for managing multiple product lists of various suppliers.

This app is used in conjunction with the [foodsoft](https://github.com/foodcoops/foodsoft).

## Setup

Copy `config/database.yml.SAMPLE` to `config/database.yml` and

    docker-compose run app bundle
    docker-compose run app rake db:setup

## Development

    docker-compose up

## Production

First build the image.

    docker build --tag sharedlists:latest --rm .

Then set environment variables `SECRET_TOKEN` and `DATABASE_URL` and run:

    docker run --name sharedlists_web \
      -e SECRET_TOKEN -e DATABASE_URL -e RAILS_FORCE_SSL=false \
      sharedlists:latest

To run cronjobs, start another instance:

    docker run --name sharedlists_cron \
      -e SECRET_TOKEN -e DATABASE_URL \
      sharedsts:latest  ./proc-start cron

