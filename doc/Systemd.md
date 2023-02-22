Running Sharedlists as a systemd service
========================================

You can use systemd to run Sharedlists and all rake tasks.
Probably you want to run the web application behind a reverse proxy that also
does the SSL termination.

1. Create a configuration file at `/etc/sharedlists/sharedlists.conf` that contains all necessary variables:
   ```Ini
   RBENV_CMD="rbenv exec"
   RAILS_ENV=production
   RAILS_FORCE_SSL=false
   RAILS_SERVE_STATIC_FILES=true
   SHAREDLISTS_BIND_IP=127.0.0.1
   SHAREDLISTS_WEB_PORT=3000
   SECRET_KEY_BASE=abc....
   MAILER_DOMAIN=example.com
   MAILER_PREFIX=sharedlists+
   SMTP_SERVER_PORT=2525
   SMTP_SERVER_HOST=127.0.0.1
   ```
1. Create a systemd socket file at `/etc/systemd/system/sharedlists-web.socket` for the web application:
   ```Ini
   [Unit]
   Description=Sharedlists HTTP Server Accept Sockets
   Documentation=https://github.com/puma/puma/blob/master/docs/systemd.md

   [Socket]
   ListenStream=127.0.0.1:9292

   # Socket options matching Puma defaults
   NoDelay=true
   ReusePort=true
   Backlog=1024

   [Install]
   WantedBy=sockets.target
   ```
1. Create a systemd service file at `/etc/systemd/system/sharedlists-web.service`:
   ```Ini
   [Unit]
   Description=Sharedlists rails server
   Documentation=https://github.com/foodcoops/sharedlists
   After=network.target
   Requires=sharedlists-web.socket

   [Service]
   Type=notify
   WatchdogSec=10
   EnvironmentFile=/etc/sharedlists/sharedlists.conf
   Restart=on-failure
   RestartSec=10
   WorkingDirectory=/opt/sharedlists
   ExecStart=/bin/bash -lc "${RBENV_CMD} rails server -b ${SHAREDLISTS_BIND_IP} -p ${SHAREDLISTS_WEB_PORT}"
   
   # Only if you created a user account to run the application
   User=sharedlists
   Group=sharedlists

   # Hardening to improve security
   NoNewPrivileges=true
   ProtectClock=true
   ProtectControlGroups=true
   ProtectHome=true
   ProtectHostname=true
   ProtectKernelLogs=true
   ProtectKernelModules=true
   ProtectKernelTunables=true
   ProtectSystem=strict
   PrivateDevices=yes
   PrivateTmp=true
   PrivateUsers=true
   ReadWritePaths=/opt/sharedlists
   RestrictRealtime=true
   RestrictSUIDSGID=true
   SystemCallArchitectures=native
   SystemCallErrorNumber=EPERM
   SystemCallFilter=@system-service

   [Install]
   WantedBy=multi-user.target
   ```
1. Your reverse proxy needs to redirect all traffic to port `9292`. Example for Nginx:
   ```
   server {
       listen 443 ssl http2;
       server_name example.com;
       ...
       location / {
           proxy_pass http://localhost:9292;
        }
   }
   ```
1. With the systemd socket you can restart the service without aborting existing connections.
1. Create another service file for the internal mail server at `/etc/systemd/system/sharedlists-smtp.service`:
   ```Ini
   [Unit]
   Description=Sharedlists smtp server
   Documentation=https://github.com/foodcoops/sharedlists
   After=network.target

   [Service]
   EnvironmentFile=/etc/sharedlists/sharedlists.conf
   Restart=on-failure
   RestartSec=10
   WorkingDirectory=/opt/sharedlists
   ExecStart=/bin/bash -lc "${RBENV_CMD} rails mail:smtp_server"

   # Only if you created a user account to run the application
   User=sharedlists
   Group=sharedlists

   # Hardening to improve security
   NoNewPrivileges=true
   ProtectClock=true
   ProtectControlGroups=true
   ProtectHome=true
   ProtectHostname=true
   ProtectKernelLogs=true
   ProtectKernelModules=true
   ProtectKernelTunables=true
   ProtectSystem=strict
   PrivateDevices=yes
   PrivateTmp=true
   PrivateUsers=true
   ReadWritePaths=/opt/sharedlists
   RestrictRealtime=true
   RestrictSUIDSGID=true
   SystemCallArchitectures=native
   SystemCallErrorNumber=EPERM
   SystemCallFilter=@system-service

   [Install]
   WantedBy=multi-user.target
   ```
