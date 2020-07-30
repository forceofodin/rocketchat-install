#!/bin/bash
#https://linuxize.com/post/secure-nginx-with-let-s-encrypt-on-ubuntu-18-04/
sudo apt update
sudo apt install certbot

sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

sudo mkdir -p /var/lib/letsencrypt/.well-known
sudo chgrp www-data /var/lib/letsencrypt
sudo chmod g+s /var/lib/letsencrypt


le_conf=/etc/nginx/snippets/letsencrypt.conf
cat > $le_conf << EOF
location ^~ /.well-known/acme-challenge/ {
  allow all;
  root /var/lib/letsencrypt/;
  default_type "text/plain";
  try_files $uri =404;
}
EOF

ssl_conf=/etc/nginx/snippets/ssl.conf
cat > $ssl_conf << EOF
ssl_dhparam /etc/ssl/certs/dhparam.pem;

ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
ssl_prefer_server_ciphers on;

ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 30s;

add_header Strict-Transport-Security "max-age=15768000; includeSubdomains; preload";
add_header X-Frame-Options SAMEORIGIN;
add_header X-Content-Type-Options nosniff;
EOF

site_nginx_conf=/etc/nginx/sites-available/clippedresistors.site.conf
site=clippedresistors.site
cat > $site_nginx_conf << EOF
server {
  listen 80;
  server_name $site;

  include snippets/letsencrypt.conf;
}
EOF

sudo ln -s /etc/nginx/sites-available/clippedresistors.site.conf /etc/nginx/sites-enabled/
sudo systemctl restart nginx
sleep 30
sudo certbot certonly --agree-tos --email alexscheppert@gmail.com --webroot -w /var/lib/letsencrypt/ -d clippedresistors.site #-d www.example.com

cat > $site_nginx_conf << EOF
upstream rocketchat_backend {
  server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name $site;

    include snippets/letsencrypt.conf;
    return 301 https://$site$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $site;

    ssl_certificate /etc/letsencrypt/live/$site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$site/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/$site/chain.pem;
    include snippets/ssl.conf;

    access_log /var/log/nginx/$site-access.log;
    error_log /var/log/nginx/$site-error.log;

    location / {
        proxy_pass http://rocketchat_backend/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forward-Proto http;
        proxy_set_header X-Nginx-Proxy true;

        proxy_redirect off;
    }
}
EOF
sudo systemctl reload nginx



