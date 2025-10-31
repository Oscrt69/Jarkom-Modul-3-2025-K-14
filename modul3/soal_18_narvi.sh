#!/bin/bash

# Script untuk Nomor 18 - Bagian 2
# Konfigurasi Database Slave di NARVI
# IP: 192.218.4.6

echo "Installing MariaDB Server on Narvi (Slave)..."

# Install MariaDB
apt-get update
apt-get install -y mariadb-server mariadb-client

# Backup default configuration
cp /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.backup

# Configure MariaDB for Slave
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

# Slave Replication Configuration
server-id               = 2
relay-log               = /var/log/mysql/mysql-relay-bin.log
log_bin                 = /var/log/mysql/mysql-bin.log
binlog_do_db            = laravel_db
read_only               = 1

# Character set
character-set-server    = utf8mb4
collation-server        = utf8mb4_unicode_ci

[embedded]
[mariadb]
[mariadb-10.11]
EOF

# Restart MariaDB
service mysql restart

# Secure MariaDB
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root_password';"

# Create Laravel database
mysql -u root -proot_password << EOF
CREATE DATABASE IF NOT EXISTS laravel_db;
CREATE USER IF NOT EXISTS 'laravel_user'@'%' IDENTIFIED BY 'laravel_password';
GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel_user'@'%';
FLUSH PRIVILEGES;
EOF

echo ""
echo "======================================"
echo "IMPORTANT: Configure Slave Replication"
echo "======================================"
echo "Get Master Status from Palantir first:"
echo "  ssh to Palantir and run:"
echo "  mysql -u root -proot_password -e 'SHOW MASTER STATUS;'"
echo ""
echo "Then run the following commands on Narvi:"
echo ""
cat << 'EOF'
mysql -u root -proot_password << EOSQL
STOP SLAVE;
CHANGE MASTER TO
  MASTER_HOST='192.218.4.5',
  MASTER_USER='replication_user',
  MASTER_PASSWORD='replication_password',
  MASTER_LOG_FILE='[MASTER_LOG_FILE]',
  MASTER_LOG_POS=[MASTER_LOG_POS];
START SLAVE;
SHOW SLAVE STATUS\G
EOSQL
EOF

echo ""
echo "Replace [MASTER_LOG_FILE] and [MASTER_LOG_POS] with values from Master Status"
echo ""
echo "To test replication:"
echo "1. On Palantir: CREATE TABLE laravel_db.test_replication (id INT PRIMARY KEY);"
echo "2. On Narvi: SHOW TABLES FROM laravel_db;"
