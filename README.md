# Sharedlists

[![Dependency Status](https://gemnasium.com/badges/github.com/foodcoops/sharedlists.svg)](https://gemnasium.com/github.com/foodcoops/sharedlists)
[![Docker Status](https://img.shields.io/docker/build/foodcoops/sharedlists.svg)](https://hub.docker.com/r/foodcoops/sharedlists)

Sharedlists is a simple rails driven database for managing multiple product lists of various suppliers.

This app is used in conjunction with [foodsoft](https://github.com/foodcoops/foodsoft).


## Development

### Setup

Copy `config/database.yml.SAMPLE` to `config/database.yml` and

    docker-compose run app bundle
    docker-compose run app rake db:setup

### Run

    docker-compose up

### Creating a user

To access sharedlists, you'll need to create a user (and I guess you want admin access).

    docker-compose run --rm app rails c
    > u = User.new(email: 'admin@example.com', password: 'secret')
    > u.admin = true
    > u.save!
    > exit

## Production

Either fetch the image, or build it:

    docker pull sharedlists:latest
    # or
    docker build --tag sharedlists:latest --rm .

Then set environment variables `SECRET_TOKEN` and `DATABASE_URL` and run:

    docker run --name sharedlists_web \
      -e SECRET_TOKEN -e DATABASE_URL -e RAILS_FORCE_SSL=false \
      sharedlists:latest

To run cronjobs, start another instance:

    docker run --name sharedlists_cron \
      -e SECRET_TOKEN -e DATABASE_URL \
      sharedlists:latest  ./proc-start cron

If you want to process incoming mails, add another instance like the previous,
substituting `mail` for `cron`.


## Updating articles

Articles in the database can be updated regularly. There are currently two options to
do this automatically.

### BNN

In Germany, there is an association for organic food, [BNN](http://n-bnn.de/), that has
a standard for distributing data over FTP. A [cron](https://en.wikipedia.org/wiki/Cron)job
needs to setup using [`whenever`](https://github.com/javan/whenever).

To enable this for a certain supplier, tick the checkbox _Synchronize BNN files_ and enter
the FTP credentials.

### Email

Some suppliers send a regular email with an article list in the attachment. For this, an
email server needs to be run using the rake task `mail:smtp_server`.
On production, you may want to run this on localhost on an unprivileged port, with a
proper [MTA](https://en.wikipedia.org/wiki/Message_transfer_agent) in front that
does message routing.

To enable this for a certain supplier, tick the checkbox _Update articles by email_. Then
select a file format to use for importing, and the supplier's email address from which the
email is sent. If you only want to import for mails with a subject that contains a certain
text (e.g. _Articles in week_), fill in the subject field as well.

What email address does the supplier need to send to? Users will find this after saving
the supplier after _Send to_.

This needs setting up of the environment variable `MAILER_DOMAIN`, on which you receive the
emails. It is allowed to prefix the address, you may want to set the prefix in `MAILER_PREFIX`.
This is useful when you're running an email server in front to route mails.
