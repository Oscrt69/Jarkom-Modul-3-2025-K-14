#!/bin/bash

# Script untuk Nomor 8
# Konfigurasi Database dan Nginx untuk Laravel Workers

# Tentukan worker dan port berdasarkan hostname
HOSTNAME=$(hostname)
case $HOSTNAME in
    "Elendil")
        PORT=8001
        ;;
    "Isildur")
        PORT=8002
        ;;
    "Anarion")
        PORT=8003
        ;;
    *)
        echo "Unknown hostname. Please run on Elendil, Isildur, or Anarion"
        exit 1
        ;;
esac

echo "Configuring Laravel Worker: $HOSTNAME on port $PORT"

# Configure .env file
cd /var/www/laravel

cat > .env << EOF
APP_NAME=Laravel
APP_ENV=production
APP_KEY=$(grep APP_KEY .env | cut -d '=' -f2)
APP_DEBUG=false
APP_URL=http://$HOSTNAME.K14.com

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=192.218.4.5
DB_PORT=3306
DB_DATABASE=laravel_db
DB_USERNAME=laravel_user
DB_PASSWORD=laravel_password

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DRIVER=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
EOF

# Configure Nginx
cat > /etc/nginx/sites-available/laravel << EOF
server {
    listen $PORT;
    server_name ${HOSTNAME,,}.k14.com;

    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
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

    error_log /var/log/nginx/laravel_error.log;
    access_log /var/log/nginx/laravel_access.log;
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart services
service php8.4-fpm restart
service nginx restart

echo "Configuration completed for $HOSTNAME"
echo "Port: $PORT"
echo "Database: Palantir (192.218.4.5)"

# Only run migrations from Elendil
if [ "$HOSTNAME" = "Elendil" ]; then
    echo "Running migrations and seeding from Elendil..."
    sleep 5  # Wait for database connection
    
    cd /var/www/laravel
    php artisan migrate --force
    php artisan db:seed --force
    
    echo "Migrations and seeding completed"
fi

echo "Laravel worker $HOSTNAME is ready on port $PORT"
echo "Access via: http://${HOSTNAME,,}.k14.com:$PORT"
