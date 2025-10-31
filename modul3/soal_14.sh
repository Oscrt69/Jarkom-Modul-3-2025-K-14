#!/bin/bash

# Script untuk Nomor 14
# Menambahkan HTTP Basic Authentication pada PHP Workers
# Jalankan di GALADRIEL, CELEBORN, OROPHER

# Tentukan worker dan port berdasarkan hostname
HOSTNAME=$(hostname)
case $HOSTNAME in
    "Galadriel")
        PORT=8004
        ;;
    "Celeborn")
        PORT=8005
        ;;
    "Oropher")
        PORT=8006
        ;;
    *)
        echo "Unknown hostname. Please run on Galadriel, Celeborn, or Oropher"
        exit 1
        ;;
esac

echo "Adding HTTP Basic Authentication for $HOSTNAME..."

# Install apache2-utils untuk htpasswd
apt-get update
apt-get install -y apache2-utils

# Create password file
# Username: noldor, Password: silvan
htpasswd -cb /etc/nginx/.htpasswd noldor silvan

# Update Nginx configuration dengan authentication
cat > /etc/nginx/sites-available/php-worker << EOF
server {
    listen $PORT;
    server_name ${HOSTNAME,,}.k14.com;

    root /var/www/html;
    index index.php index.html;

    # HTTP Basic Authentication
    auth_basic "Restricted Access - Taman Peri";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    error_log /var/log/nginx/php_worker_error.log;
    access_log /var/log/nginx/php_worker_access.log;
}
EOF

# Test Nginx configuration
nginx -t

# Reload Nginx
service nginx reload

echo "HTTP Basic Authentication configured for $HOSTNAME"
echo "Username: noldor"
echo "Password: silvan"
echo ""
echo "Testing authentication..."

# Test without credentials (should fail)
echo "Test without credentials (should get 401):"
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:$PORT/index.php

# Test with credentials (should work)
echo "Test with credentials (should get 200):"
curl -s -o /dev/null -w "%{http_code}\n" -u noldor:silvan http://localhost:$PORT/index.php

echo ""
echo "Authentication is active. Access requires username 'noldor' and password 'silvan'"
