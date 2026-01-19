#!/bin/bash
yum update -y
yum install nginx openssl -y

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 \
-newkey rsa:2048 \
-keyout /etc/nginx/ssl/nginx.key \
-out /etc/nginx/ssl/nginx.crt \
-subj "/C=PK/ST=Sindh/L=Karachi/O=Terraform/OU=Dev/CN=localhost"

cat > /etc/nginx/conf.d/ssl.conf <<EOF
server {
    listen 80;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
EOF

echo "<h1>This is zunairakhatoon Terraform environment</h1>" > /usr/share/nginx/html/index.html

systemctl enable nginx
systemctl start nginx
