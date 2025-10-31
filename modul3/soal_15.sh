#!/bin/bash

# Script untuk Nomor 15
# Menambahkan X-Real-IP header dan menampilkan IP pengunjung
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

echo "Adding X-Real-IP header support for $HOSTNAME..."

# Update Nginx configuration dengan X-Real-IP header
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
        
        # Pass X-Real-IP header to PHP
        fastcgi_param HTTP_X_REAL_IP \$remote_addr;
        fastcgi_param X_REAL_IP \$remote_addr;
    }

    location ~ /\.ht {
        deny all;
    }

    error_log /var/log/nginx/php_worker_error.log;
    access_log /var/log/nginx/php_worker_access.log;
}
EOF

# Update index.php to display visitor IP
cat > /var/www/html/index.php << 'EOF'
<?php
// Function to get real IP address
function getRealIpAddr() {
    // Check for X-Real-IP header first
    if (isset($_SERVER['HTTP_X_REAL_IP'])) {
        return $_SERVER['HTTP_X_REAL_IP'];
    }
    // Check for X-Forwarded-For header
    elseif (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ipList = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        return trim($ipList[0]);
    }
    // Fallback to REMOTE_ADDR
    elseif (isset($_SERVER['REMOTE_ADDR'])) {
        return $_SERVER['REMOTE_ADDR'];
    }
    return 'UNKNOWN';
}

echo "=== Taman Peri - " . gethostname() . " ===\n";
echo "Hostname: " . gethostname() . "\n";
echo "Server IP: " . (isset($_SERVER['SERVER_ADDR']) ? $_SERVER['SERVER_ADDR'] : 'N/A') . "\n";
echo "Visitor IP (Real): " . getRealIpAddr() . "\n";
echo "Client IP (Direct): " . (isset($_SERVER['REMOTE_ADDR']) ? $_SERVER['REMOTE_ADDR'] : 'N/A') . "\n";
echo "Date/Time: " . date('Y-m-d H:i:s') . "\n";
echo "Request URI: " . (isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : 'N/A') . "\n";

// Debug headers
if (isset($_SERVER['HTTP_X_REAL_IP'])) {
    echo "X-Real-IP Header: " . $_SERVER['HTTP_X_REAL_IP'] . "\n";
}
if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    echo "X-Forwarded-For Header: " . $_SERVER['HTTP_X_FORWARDED_FOR'] . "\n";
}
?>
EOF

# Set permissions
chown www-data:www-data /var/www/html/index.php
chmod 644 /var/www/html/index.php

# Test and reload Nginx
nginx -t
service nginx reload

echo "X-Real-IP header configuration completed for $HOSTNAME"
echo "index.php updated to display visitor's real IP address"
echo ""
echo "Testing..."
curl -u noldor:silvan http://localhost:$PORT/index.php
