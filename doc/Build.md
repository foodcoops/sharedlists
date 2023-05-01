Build Sharedlists
===================

This document describes how to setup Sharedlists  within your local system. If you want to run Sharedlists in production you have to setup the following environment variables:
- `RAILS_ENV=production`
- `SECRET_KEY_BASE=abc....`

**System requirements**:
- [rbenv](https://github.com/rbenv/rbenv)
- [Ruby 2.7+](https://www.ruby-lang.org/en/downloads/)
- [Bundler](http://bundler.io/)
- [MySQL](http://mysql.com/) or [SQLite](http://sqlite.org/)

## Getting started

1. Clone the repository from GitHub:
    ```
    git clone https://github.com/foodcoops/sharedlists.git
    ```
2. Install and setup rbenv and Bundler. For Debian/Ubuntu:
    ```
    sudo apt install rbenv libyaml-dev
    ```
     
    For other distributions have a look at the rbenv [documentation](https://github.com/rbenv/rbenv).

1. Add the following line to your `.bashrc`:
   ```
    eval "$(rbenv init -)"
   ```
1. Install [ruby-build](https://github.com/rbenv/ruby-build):
    ```Shell
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    ```
1. Change to the Sharedlists directory and install the [recommended](https://github.com/foodcoops/sharedlists/blob/master/.ruby-version)
    Ruby version:
    ```
    rbenv install "$(cat .ruby-version)"
    ```
1. Now you can install [Bundler](https://bundler.io/):
    ```
    rbenv exec gem install bundler
    ```
2. Install system dependencies. For Debian/Ubuntu, that's:
    ```Shell
    sudo apt install libv8-dev default-libmysqlclient-dev libxml2-dev libxslt1-dev libffi-dev libreadline-dev libmagic-dev
    ```

   For CentOS/Redhat you need:
   ```Shell
    sudo yum install v8 community-mysql-devel libxml2-devel libxslt-devel libffi-devel readline-devel file-devel
    ```
3. Install Ruby dependencies:
    ```
    rbenv exec bundle install
    ```
4. Copy `config/database.yml.SAMPLE` to `config/database.yml`, adapt to your needs and setup your database:
    ```
    rbenv exec bundle exec rails db:setup
    ```
5. Precompile all assets:
    ```
    rbenv exec bundle exec rails assets:precompile
    ```
6. Start the rails server by running:
    ```
    rbenv exec bundle exec rails s
    ```
7. Open your favorite browser and open the web browser at http://localhost:3000/
8. Login using the default credentials: `admin@example.com/secret`
9. For a production setup you run Sharedlists as a systemd service. You will find more information [here](Systemd.md).
