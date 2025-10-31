#!/bin/bash

# Script untuk Nomor 20
# Implementasi Nginx Caching pada Pharazon
# IP: 192.218.2.36

echo "Adding Nginx Caching to Pharazon Load Balancer..."

# Create cache directory
mkdir -p /var/cache/nginx/pharazon_cache
chown www-data:www-data /var/cache/nginx/pharazon_cache
chmod 755 /var/cache/nginx/pharazon_cache

# Update Nginx configuration dengan caching
cat > /etc/nginx/sites-available/pharazon << EOF
# Rate limiting zone
limit_req_zone \$binary_remote_addr zone=php_limit:10m rate=10r/s;

# Cache configuration
proxy_cache_path /var/cache/nginx/pharazon_cache levels=1:2 keys_zone=pharazon_cache:10m max_size=100m inactive=60m use_temp_path=off;

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
        # Enable caching
        proxy_cache pharazon_cache;
        proxy_cache_valid 200 302 10m;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_lock on;
        
        # Add cache status to response header
        add_header X-Cache-Status \$upstream_cache_status always;
        
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

echo "Nginx caching configured on Pharazon"
echo "Cache location: /var/cache/nginx/pharazon_cache"
echo "Cache valid time: 10 minutes for 200/302, 1 minute for 404"
echo "Cache size: max 100MB"
echo ""
echo "Testing cache functionality..."

apt-get install -y curl

echo ""
echo "First request (should be MISS):"
curl -I -u noldor:silvan http://pharazon.k14.com/index.php 2>&1 | grep -E "HTTP|X-Cache-Status"

sleep 2

echo ""
echo "Second request (should be HIT):"
curl -I -u noldor:silvan http://pharazon.k14.com/index.php 2>&1 | grep -E "HTTP|X-Cache-Status"

sleep 2

echo ""
echo "Third request (should be HIT):"
curl -I -u noldor:silvan http://pharazon.k14.com/index.php 2>&1 | grep -E "HTTP|X-Cache-Status"

echo ""
echo "Cache status indicators:"
echo "  MISS - Content not in cache, fetched from backend"
echo "  HIT - Content served from cache"
echo "  BYPASS - Request bypassed cache"
echo "  EXPIRED - Cached content expired, refetched from backend"
echo ""
echo "To clear cache: rm -rf /var/cache/nginx/pharazon_cache/*"
echo "To check cache size: du -sh /var/cache/nginx/pharazon_cache/"
