#!/bin/bash
set -e

########################################
# Update system and install dependencies
########################################
yum update -y
yum install -y nginx openssl curl jq

systemctl start nginx
systemctl enable nginx

########################################
# SSL directories
########################################
mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

########################################
# Get EC2 metadata token & IPs
########################################
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
PUBLIC_DNS=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname)

########################################
# Determine Web label
########################################
WEB_LABEL="Unknown"
if [ "$PRIVATE_IP" = "10.0.10.183" ]; then
    WEB_LABEL="Web-1"
elif [ "$PRIVATE_IP" = "10.0.10.60" ]; then
    WEB_LABEL="Web-2"
elif [ "$PRIVATE_IP" = "10.0.10.174" ]; then
    WEB_LABEL="Web-3 (backup)"
fi

########################################
# Generate self-signed SSL certificate
########################################
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/selfsigned.key \
  -out /etc/ssl/certs/selfsigned.crt \
  -subj "/CN=$PUBLIC_IP" \
  -addext "subjectAltName=IP:$PUBLIC_IP" \
  -addext "basicConstraints=CA:FALSE" \
  -addext "keyUsage=digitalSignature,keyEncipherment" \
  -addext "extendedKeyUsage=serverAuth"

echo "SSL certificate created for IP: $PUBLIC_IP"

########################################
# Backup default Nginx config
########################################
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

########################################
# Create index.html with full info
########################################
cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Backend Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; background: #282c34; color: #fff; padding: 50px; }
        h1 { color: #61dafb; }
        .info { margin: 10px 0; }
        .label { font-weight: bold; color: #ffd700; }
    </style>
</head>
<body>

    <h1>🚀 $WEB_LABEL - Assignment 2</h1>
    <div class="info"><span class="label">Hostname:</span> $(hostname)</div>
    <div class="info"><span class="label">Private IP:</span> $PRIVATE_IP</div>
    <div class="info"><span class="label">Public IP:</span> $PUBLIC_IP</div>
    <div class="info"><span class="label">Public DNS:</span> $PUBLIC_DNS</div>
    <div class="info"><span class="label">Deployed at:</span> $(date)</div>
    <div class="info"><span class="label">Status:</span> ✅ Active and Running</div>
    <div class="info"><span class="label">Managed By:</span> Terraform</div>
</body>
</html>
EOF

chmod 644 /usr/share/nginx/html/index.html

########################################
# Backend private IPs
########################################
BACKEND1="10.0.10.183"
BACKEND2="10.0.10.60"
BACKEND3="10.0.10.174"

########################################
# Nginx configuration template
########################################
cat > /etc/nginx/nginx.conf <<'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    'Cache:$upstream_cache_status';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    types_hash_max_size 4096;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    proxy_cache_path /var/cache/nginx
        levels=1:2
        keys_zone=my_cache:10m
        max_size=1g
        inactive=60m
        use_temp_path=off;

    upstream backend_servers {
        server BACKEND_IP_1:80;
        server BACKEND_IP_2:80;
        server BACKEND_IP_3:80 backup;
    }

    server {
        listen 443 ssl http2;
        server_name _;

        ssl_certificate /etc/ssl/certs/selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/selfsigned.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;

        location / {
            proxy_pass http://backend_servers;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_cache my_cache;
            proxy_cache_valid 200 60m;
            proxy_cache_valid 404 10m;
            proxy_cache_key "$scheme$request_method$host$request_uri";
            proxy_cache_bypass $http_cache_control;

            add_header X-Cache-Status $upstream_cache_status;

            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        location /health {
            access_log off;
            add_header Content-Type text/plain;
            return 200 "Nginx is healthy\n";
        }
    }

    server {
        listen 80;
        server_name _;

        location / {
            return 301 https://$host$request_uri;
        }

        location /health {
            access_log off;
            add_header Content-Type text/plain;
            return 200 "Nginx is healthy\n";
        }
    }
}
EOF

########################################
# Replace backend placeholders
########################################
sed -i "s/BACKEND_IP_1/$BACKEND1/g" /etc/nginx/nginx.conf
sed -i "s/BACKEND_IP_2/$BACKEND2/g" /etc/nginx/nginx.conf
sed -i "s/BACKEND_IP_3/$BACKEND3/g" /etc/nginx/nginx.conf

########################################
# Cache directory
########################################
mkdir -p /var/cache/nginx
chown -R nginx:nginx /var/cache/nginx

########################################
# Test and restart Nginx
########################################
nginx -t
systemctl restart nginx

echo "✅ Nginx setup completed successfully!"
echo "⚠️  Backend IPs have been automatically updated in /etc/nginx/nginx.conf"
