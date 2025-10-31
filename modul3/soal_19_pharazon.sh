#!/bin/bash

# Script untuk Nomor 19 - Bagian 2
# Implementasi Rate Limiting pada Pharazon (PHP Load Balancer)
# IP: 192.218.2.36

echo "Adding Rate Limiting to Pharazon Load Balancer..."

# Update Nginx configuration dengan rate limiting
cat > /etc/nginx/sites-available/pharazon << EOF
# Rate limiting zone: 10 requests per second per IP
limit_req_zone \$binary_remote_addr zone=php_limit:10m rate=10r/s;

upstream kesatria_lorien {
    server 192.218.2.3:8004;  # Galadriel
    server 192.218.2.4:8005;  # Celeborn
    server 192.218.2.5:8006;  # Oropher
}

server {
    listen 80;
    server_name pharazon.k14.com;

    # Apply rate limiting
    limit_req zone=php_limit burst=20 nodelay;
    limit_req_status 429;

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

# Test and reload Nginx
nginx -t
service nginx reload

echo "Rate limiting configured on Pharazon"
echo "Limit: 10 requests per second per IP"
echo "Burst: 20 requests"
echo "Status code for rate limited requests: 429"
echo ""
echo "Testing rate limiting with authentication..."

apt-get install -y apache2-utils curl

echo "Sending burst of requests to trigger rate limit..."
for i in {1..30}; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" -u noldor:silvan http://pharazon.k14.com/)
    echo "Request $i: HTTP $STATUS"
    if [ "$STATUS" = "429" ]; then
        echo "  ^^^ Rate limit triggered!"
    fi
done

echo ""
echo "Check error log for rate limit messages:"
echo "tail -f /var/log/nginx/pharazon_error.log | grep limiting"
