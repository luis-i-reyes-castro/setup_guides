# SSL Certificate Acquisition (`https`)

Example situation:
  * Rented VPS/droplet and SSH'ed into it
  * Bought domain `sofia-systems.com`

### Install Certbot from Let's Encrypt and Request certificate

```
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx 
sudo certbot --nginx -d sofia-systems.com -d www.sofia-systems.com -d wa.sofia-systems.com
```

### Setup Reverse-proxy

Run `nano /etc/nginx/sites-available/sofia-systems.conf` and paste the following script:

```bash
#
# Reverse-proxy configuration for sofia-systems.com
# Copy to /etc/nginx/sites-available/sofia-systems.conf on the droplet,
# then `ln -s` into sites-enabled and `sudo nginx -t && sudo systemctl reload nginx`.
#

upstream frontend_app {
    server 127.0.0.1:8081;
    keepalive 16;
}

upstream whatsapp_backend {
    server 127.0.0.1:8080;
    keepalive 8;
}

server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name sofia-systems.com www.sofia-systems.com;

    ssl_certificate     /etc/letsencrypt/live/sofia-systems.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sofia-systems.com/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://frontend_app;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    listen [::]:80;
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name wa.sofia-systems.com;

    ssl_certificate     /etc/letsencrypt/live/sofia-systems.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sofia-systems.com/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://whatsapp_backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Disable Default Site and Enable New Site

```bash
sudo rm -v /etc/nginx/sites-enabled/default 
sudo ln -sf /etc/nginx/sites-available/sofia-systems.conf /etc/nginx/sites-enabled/sofia-systems.conf
```

### Validate Nginx Configuration

```bash
sudo nginx -t
```

### Start Nginx service

```bash
sudo systemctl start nginx
```
