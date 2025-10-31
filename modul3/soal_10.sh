#!/bin/bash

# Script untuk Nomor 10
# Konfigurasi Load Balancer di ELROS untuk Laravel Workers
# IP: 192.218.1.35

echo "Installing and configuring Nginx Load Balancer on Elros..."

# Install Nginx
apt-get update
apt-get install -y nginx

# Backup default configuration
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Configure Nginx as Load Balancer for Laravel
cat > /etc/nginx/sites-available/elros << EOF
upstream kesatria_numenor {
    server 192.218.1.37:8001;  # Elendil
    server 192.218.1.38:8002;  # Isildur
    server 192.218.1.39:8003;  # Anarion
}

server {
    listen 80;
    server_name elros.k14.com;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_log /var/log/nginx/elros_error.log;
    access_log /var/log/nginx/elros_access.log;
}
EOF

# Enable site and disable default
ln -sf /etc/nginx/sites-available/elros /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
service nginx restart
service nginx status

echo "Elros Load Balancer configured successfully"
echo "Upstream: kesatria_numenor"
echo "  - Elendil: 192.218.1.37:8001"
echo "  - Isildur: 192.218.1.38:8002"
echo "  - Anarion: 192.218.1.39:8003"
echo ""
echo "Algorithm: Round Robin (default)"
echo "Access via: http://elros.k14.com"
echo ""
echo "Testing load balancer..."

# Test from Elros itself
apt-get install -y curl

for i in {1..6}; do
    echo "Request $i:"
    curl -s http://elros.k14.com/api/airing | head -n 5
    echo ""
    sleep 1
done

echo "Check /var/log/nginx/elros_access.log to see request distribution"
