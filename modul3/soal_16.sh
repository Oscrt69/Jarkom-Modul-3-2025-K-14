#!/bin/bash

# Script untuk Nomor 16
# Konfigurasi Load Balancer di PHARAZON untuk PHP Workers
# IP: 192.218.2.36

echo "Installing and configuring Nginx Load Balancer on Pharazon..."

# Install Nginx
apt-get update
apt-get install -y nginx

# Backup default configuration
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Configure Nginx as Load Balancer for PHP Workers
cat > /etc/nginx/sites-available/pharazon << EOF
upstream kesatria_lorien {
    server 192.218.2.3:8004;  # Galadriel
    server 192.218.2.4:8005;  # Celeborn
    server 192.218.2.5:8006;  # Oropher
}

server {
    listen 80;
    server_name pharazon.k14.com;

    location / {
        proxy_pass http://kesatria_lorien;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Forward Basic Authentication headers
        proxy_set_header Authorization \$http_authorization;
        proxy_pass_header Authorization;
    }

    error_log /var/log/nginx/pharazon_error.log;
    access_log /var/log/nginx/pharazon_access.log;
}
EOF

# Enable site and disable default
ln -sf /etc/nginx/sites-available/pharazon /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
service nginx restart
service nginx status

echo "Pharazon Load Balancer configured successfully"
echo "Upstream: kesatria_lorien"
echo "  - Galadriel: 192.218.2.3:8004"
echo "  - Celeborn: 192.218.2.4:8005"
echo "  - Oropher: 192.218.2.5:8006"
echo ""
echo "Algorithm: Round Robin (default)"
echo "Access via: http://pharazon.k14.com"
echo "Authentication credentials forwarded to backend workers"
echo ""
echo "Testing load balancer with authentication..."

# Install curl
apt-get install -y curl

# Test with authentication
for i in {1..6}; do
    echo "Request $i:"
    curl -u noldor:silvan http://pharazon.k14.com/index.php
    echo ""
    sleep 1
done

echo "Check /var/log/nginx/pharazon_access.log to see request distribution"
