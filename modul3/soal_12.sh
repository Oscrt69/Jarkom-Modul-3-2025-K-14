#!/bin/bash

# Script untuk Nomor 12
# Install PHP Workers di GALADRIEL, CELEBORN, OROPHER
# Jalankan script ini di ketiga worker

echo "Installing PHP Worker requirements..."

# Update packages
apt-get update

# Install PHP 8.4 and FPM
apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2

# Add PHP repository
curl -sSL https://packages.sury.org/php/README.txt | bash -x
apt-get update

# Install PHP 8.4 FPM
apt-get install -y php8.4-fpm php8.4-cli php8.4-common

# Install Nginx
apt-get install -y nginx

# Get hostname
HOSTNAME=$(hostname)

echo "Creating simple PHP page for $HOSTNAME..."

# Create web root
mkdir -p /var/www/html

# Create index.php
cat > /var/www/html/index.php << 'EOF'
<?php
echo "Hostname: " . gethostname() . "\n";
echo "Server IP: " . $_SERVER['SERVER_ADDR'] . "\n";
echo "Client IP: " . $_SERVER['REMOTE_ADDR'] . "\n";
echo "Date/Time: " . date('Y-m-d H:i:s') . "\n";
?>
EOF

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "PHP Worker $HOSTNAME installation completed"
echo "Next step: Configure Nginx (Script 13)"
echo "Web root: /var/www/html"
