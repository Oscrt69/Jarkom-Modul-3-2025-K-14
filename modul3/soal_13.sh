#!/bin/bash

# Script untuk Nomor 13
# Konfigurasi Nginx untuk PHP Workers
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

echo "Configuring Nginx for PHP Worker: $HOSTNAME on port $PORT"

# Configure Nginx
cat > /etc/nginx/sites-available/php-worker << EOF
server {
    listen $PORT;
    server_name ${HOSTNAME,,}.k14.com;

    root /var/www/html;
    index index.php index.html;

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

# Enable site
ln -sf /etc/nginx/sites-available/php-worker /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart services
service php8.4-fpm restart
service nginx restart

echo "Configuration completed for $HOSTNAME"
echo "Port: $PORT"
echo "Testing PHP worker..."

# Test locally
apt-get install -y curl
sleep 2
curl http://localhost:$PORT/index.php

echo ""
echo "PHP worker $HOSTNAME is ready on port $PORT"
echo "Access via: http://${HOSTNAME,,}.k14.com:$PORT"
