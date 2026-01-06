#!/bin/bash
set -e

########################################
# Update system and install Apache
########################################
yum update -y
yum install -y httpd curl jq

systemctl start httpd
systemctl enable httpd

########################################
# Get EC2 metadata token & IPs
########################################
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
PUBLIC_DNS=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname)
HOSTNAME=$(hostname)

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
# Create index.html with full info
########################################
cat > /var/www/html/index.html <<EOF
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
    <div class="info"><span class="label">Hostname:</span> $HOSTNAME</div>
    <div class="info"><span class="label">Private IP:</span> $PRIVATE_IP</div>
    <div class="info"><span class="label">Public IP:</span> $PUBLIC_IP</div>
    <div class="info"><span class="label">Public DNS:</span> $PUBLIC_DNS</div>
    <div class="info"><span class="label">Deployed at:</span> $(date)</div>
    <div class="info"><span class="label">Status:</span> ✅ Active and Running</div>
    <div class="info"><span class="label">Managed By:</span> Terraform</div>
</body>
</html>
EOF

chmod 644 /var/www/html/index.html

########################################
# Test and restart Apache
########################################
systemctl restart httpd

echo "✅ Apache setup completed successfully!"
echo "⚠️  Open the public IP or DNS in your browser to verify Web label."
