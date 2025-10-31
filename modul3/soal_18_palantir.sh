#!/bin/bash

# Script untuk Nomor 18
# Konfigurasi Database Master di PALANTIR
# IP: 192.218.4.5

echo "Installing MariaDB Server on Palantir (Master)..."

# Install MariaDB
apt-get update
apt-get install -y mariadb-server mariadb-client

# Backup default configuration
cp /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.backup

# Configure MariaDB for Master
cat > /etc/mysql/mariadb.conf.d/50-server.cnf << EOF
[server]
[mysqld]
user                    = mysql
pid-file                = /run/mysqld/mysqld.pid
basedir                 = /usr
datadir                 = /var/lib/mysql
tmpdir                  = /tmp
lc-messages-dir         = /usr/share/mysql
lc-messages             = en_US

# Bind to all interfaces
bind-address            = 0.0.0.0

# Master Replication Configuration
server-id               = 1
log_bin                 = /var/log/mysql/mysql-bin.log
binlog_do_db            = laravel_db
max_binlog_size         = 100M
binlog_format           = ROW

# Character set
character-set-server    = utf8mb4
collation-server        = utf8mb4_unicode_ci

[embedded]
[mariadb]
[mariadb-10.11]
EOF

# Restart MariaDB
service mysql restart

# Secure MariaDB and create databases/users
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root_password';"

# Create Laravel database and user
mysql -u root -proot_password << EOF
CREATE DATABASE IF NOT EXISTS laravel_db;
CREATE USER IF NOT EXISTS 'laravel_user'@'%' IDENTIFIED BY 'laravel_password';
GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel_user'@'%';

-- Create replication user for slave
CREATE USER IF NOT EXISTS 'replication_user'@'%' IDENTIFIED BY 'replication_password';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';

FLUSH PRIVILEGES;
EOF

echo "Getting Master status..."
mysql -u root -proot_password -e "SHOW MASTER STATUS;"

echo ""
echo "MariaDB Master (Palantir) configured successfully"
echo "Database: laravel_db"
echo "User: laravel_user / laravel_password"
echo "Replication User: replication_user / replication_password"
echo ""
echo "Save the Master Status (File and Position) for Slave configuration!"
echo "Run: mysql -u root -proot_password -e 'SHOW MASTER STATUS;'"
