#!/bin/bash

# Script untuk Nomor 19
# Implementasi Rate Limiting pada Elros (Laravel Load Balancer)
# IP: 192.218.1.35

echo "Adding Rate Limiting to Elros Load Balancer..."

# Update Nginx configuration dengan rate limiting
cat > /etc/nginx/sites-available/elros << EOF
# Rate limiting zone: 10 requests per second per IP
limit_req_zone \$binary_remote_addr zone=laravel_limit:10m rate=10r/s;

upstream kesatria_numenor {
    server 192.218.1.37:8001 weight=3;  # Elendil
    server 192.218.1.38:8002 weight=2;  # Isildur
    server 192.218.1.39:8003 weight=1;  # Anarion
}

server {
    listen 80;
    server_name elros.k14.com;

    # Apply rate limiting
    limit_req zone=laravel_limit burst=20 nodelay;
    limit_req_status 429;

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

# Test and reload Nginx
nginx -t
service nginx reload

echo "Rate limiting configured on Elros"
echo "Limit: 10 requests per second per IP"
echo "Burst: 20 requests"
echo "Status code for rate limited requests: 429"
echo ""
echo "Testing rate limiting..."

apt-get install -y apache2-utils curl

echo "Sending burst of requests to trigger rate limit..."
for i in {1..30}; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://elros.k14.com/)
    echo "Request $i: HTTP $STATUS"
    if [ "$STATUS" = "429" ]; then
        echo "  ^^^ Rate limit triggered!"
    fi
done

echo ""
echo "Check error log for rate limit messages:"
echo "tail -f /var/log/nginx/elros_error.log | grep limiting"

