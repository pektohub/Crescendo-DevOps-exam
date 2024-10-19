#!/bin/bash
# Update and install Nginx and JRE
apt update -y
apt install -y nginx unzip zip wget openssl default-jre -y

# Generate self-signed SSL
mkdir /opt/ssl
cd /opt/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout private.key -out fullchain.crt -subj "/CN=localhost"

# Download and Start Magnolia CMS
cd /opt
wget https://nexus.magnolia-cms.com/repository/public/info/magnolia/bundle/magnolia-community-demo-webapp/6.2.50/magnolia-community-demo-webapp-6.2.50-tomcat-bundle.zip
unzip *.zip
cd magnolia-6.2.50/apache-tomcat-9.0.93/bin
./magnolia_control.sh start --ignore-open-files-limit


# Modify nginx.conf
cat <<'EOF' > /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 768;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Your server block for HTTP (port 80) and HTTPS (port 443)
    server {
        listen 80;
        server_name _;
        # Redirect all HTTP traffic to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl;
        server_name _;

        ssl_certificate /opt/ssl/fullchain.crt;
        ssl_certificate_key /opt/ssl/private.key;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers HIGH:!aNULL:!MD5;

        location / {
            proxy_pass http://localhost:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Additional includes if needed
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
systemctl enable nginx
systemctl start nginx
sleep 10
systemctl restart nginx
