FROM ruby:2.7.7

RUN supercronicUrl=https://github.com/aptible/supercronic/releases/download/v0.2.1/supercronic-linux-amd64 && \
    supercronicBin=/usr/local/bin/supercronic && \
    supercronicSha1sum=d7f4c0886eb85249ad05ed592902fa6865bb9d70 && \
    curl -fsSL -o "$supercronicBin" "$supercronicUrl" && \
    echo "$supercronicSha1sum  $supercronicBin" | sha1sum -c - && \
    chmod +x "$supercronicBin"

ENV PORT=3000 \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

WORKDIR /usr/src/app

COPY . ./

# install dependencies, recognize database_url, generate crontab
RUN echo 'gem: --no-document' >> ~/.gemrc && \
    bundle config build.nokogiri "--use-system-libraries" && \
    bundle install --deployment --without development test -j 4 && \
    yarn && \
    rm -Rf /var/lib/apt/lists/* /var/cache/apt/* ~/.gemrc ~/.bundle && \
    \
    echo "production:\n  url: <%= ENV['DATABASE_URL'] %>" >config/database.yml && \
    bundle exec whenever >crontab

# compile assets with temporary mysql server
RUN export DATABASE_URL=mysql2://localhost/temp && \
    export SECRET_KEY_BASE=thisisnotimportantnow && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y mariadb-server yarn && \
    /usr/sbin/service mariadb start && \
    bundle exec rails db:setup assets:precompile && \
    rm -Rf tmp/* && \
    /usr/sbin/service mariadb stop && \
    rm -Rf /run/mysqld /tmp/* /var/tmp/* /var/lib/mysql /var/log/mysql* && \
    apt-get purge -y --auto-remove mariadb-server yarn && \
    rm -Rf /var/lib/apt/lists/* /var/cache/apt/*

# Make relevant dirs writable for app user
RUN mkdir -p tmp supplier_assets && \
    chown nobody tmp supplier_assets

# Run app as unprivileged user
USER nobody

EXPOSE 3000

# cleanup, and by default start web process from Procfile
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["./proc-start", "web"]
