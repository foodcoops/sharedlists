# Sharedlists

[![Docker Status](https://img.shields.io/docker/build/foodcoops/sharedlists.svg)](https://hub.docker.com/r/foodcoops/sharedlists)

Sharedlists is a simple rails driven database for managing multiple product lists of various suppliers.

This app is used in conjunction with [foodsoft](https://github.com/foodcoops/foodsoft).
Recommended [Ruby](http://ruby-lang.org/) version is 2.7.


## Development

### Setup

Copy `config/database.yml.SAMPLE` to `config/database.yml` and

    docker-compose run --rm app bundle
    docker-compose run --rm app rails db:setup

### Run

    docker-compose up

### Login

Login using the default credentials: admin@example.com/secret and update the account details to your needs.
You can create more users within the web interface.

## Production

Either fetch the image, or build it:

    docker pull sharedlists:latest
    # or
    docker build --tag sharedlists:latest --rm .

Then set environment variables `SECRET_KEY_BASE` and `DATABASE_URL` and run:

    docker run --name sharedlists_web \
      -e SECRET_KEY_BASE -e DATABASE_URL -e RAILS_FORCE_SSL=false \
      sharedlists:latest

To run cronjobs, start another instance:

    docker run --name sharedlists_cron \
      -e SECRET_KEY_BASE -e DATABASE_URL \
      sharedlists:latest  ./proc-start cron

If you want to process incoming mails, add another instance like the previous,
substituting `mail` for `cron`.

To put this all together, you may want to wrap this in docker-compose. See
the [foodcoops.net setup](https://github.com/foodcoops/foodcoops.net/) for a real-world example.


## Connecting Foodsoft

To use shared suppliers from this sharedlists instance from within Foodsoft, you need
to configure the [`shared_lists` option](https://github.com/foodcoops/foodsoft/blob/31689dfb75d203ab39405c313817e8c40e2cab36/config/app_config.yml.SAMPLE#L154)
in its `config/app_config.yml`. Don't forget to grant the Foodsoft database user
`SELECT` access on sharedlists' `suppliers` and `articles` tables.


## Updating articles

Articles in the database can be updated regularly. There are currently two options to
do this automatically.

### FTP

Some suppliers distribute article lists via FTP. You can use the rake task
called `sync_ftp_files` in order to download and parse those article
lists. First, you need to enable FTP synchronization for a certain supplier by
activating the checkbox _Synchronize FTP files_. Fill out all corresponding form
fields. In particular, make sure to adjust the *file filter (regular
expression)* such that it matches the files of interest; non-matching files are
ignored. The two supported file formats and sensible choices for a corresponding
*file filter* are shown in the following table.

| file format                 | example file filter           |
|-----------------------------|-------------------------------|
| [BNN3][bnn3-format]         | `\A(?:[.]/)?PL.{0,6}[.]BNN\z` |
| [foodsoft][foodsoft-format] | `\A(?:[.]/)?.+[.]csv\z`       |

[bnn3-format]: https://github.com/foodcoops/foodsoft/wiki/File-formats-for-article-lists#user-content-format-bnn3
[foodsoft-format]: https://github.com/foodcoops/foodsoft/wiki/File-formats-for-article-lists#user-content-format-foodsoft

Once you have the `sync_ftp_files` task working, you may wish to setup a
[cron](https://en.wikipedia.org/wiki/Cron)job using
[`whenever`](https://github.com/javan/whenever).

### Email

Some suppliers send a regular email with an article list in the attachment. For this, an
email server needs to be run using the rails task `mail:smtp_server`.
On production, you may want to run this on localhost on an unprivileged port, with a
proper [MTA](https://en.wikipedia.org/wiki/Message_transfer_agent) in front that
does message routing.

To enable this for a certain supplier, tick the checkbox _Update articles by email_. Then
select a file format to use for importing, and the supplier's email address from which the
email is sent. If you only want to import mails with a subject that contains a certain
text (e.g. _Articles in week_), fill in the subject field as well.

What email address does the supplier need to send to? Users will find this after initial creating and
saving the supplier after _Send to_.

This needs setting up of the environment variable `MAILER_DOMAIN`, on which you receive the
mails. It is allowed to prefix the address, you may want to set the prefix in `MAILER_PREFIX`.
This is useful when you're running a mail server in front to route mails.