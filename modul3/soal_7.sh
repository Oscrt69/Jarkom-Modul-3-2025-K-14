#!/bin/bash

# Script untuk Nomor 7
# Install Laravel Workers di ELENDIL, ISILDUR, ANARION
# Jalankan script ini di ketiga worker

echo "Installing Laravel Worker requirements..."

# Update packages
apt-get update

# Install PHP 8.4 and required extensions
apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2

# Add PHP repository
curl -sSL https://packages.sury.org/php/README.txt | bash -x
apt-get update

# Install PHP 8.4 and extensions
apt-get install -y php8.4 php8.4-cli php8.4-fpm php8.4-common php8.4-mysql \
    php8.4-zip php8.4-gd php8.4-mbstring php8.4-curl php8.4-xml php8.4-bcmath

# Install Nginx
apt-get install -y nginx

# Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install git and unzip
apt-get install -y git unzip

# Clone Laravel project
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git
mv laravel-simple-rest-api laravel

# Set ownership and permissions
chown -R www-data:www-data /var/www/laravel
chmod -R 755 /var/www/laravel
chmod -R 775 /var/www/laravel/storage
chmod -R 775 /var/www/laravel/bootstrap/cache

# Install Laravel dependencies
cd /var/www/laravel
composer install --no-dev --optimize-autoloader

# Copy .env file
cp .env.example .env

# Generate application key
php artisan key:generate

echo "Laravel Worker installation completed"
echo "Next step: Configure database connection in .env file (Script 8)"
echo "Location: /var/www/laravel"

# Show Laravel version
php artisan --version
