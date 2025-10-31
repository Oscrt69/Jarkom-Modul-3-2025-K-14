#!/bin/bash

# Script untuk Nomor 4 - Bagian 2
# Konfigurasi DNS Slave di AMDIR
# IP: 192.218.3.3

echo "Installing DNS Slave (BIND9) on Amdir..."

# Install BIND9
apt-get update
apt-get install bind9 bind9utils dnsutils -y

# Backup konfigurasi default
cp /etc/bind/named.conf.local /etc/bind/named.conf.local.backup
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup

# Konfigurasi BIND9 Options
cat > /etc/bind/named.conf.options << EOF
options {
    directory "/var/cache/bind";

    allow-query { any; };
    listen-on { any; };
    listen-on-v6 { none; };

    # Forwarder
    forwarders {
        192.168.122.1;
    };

    dnssec-validation auto;
    auth-nxdomain no;
};
EOF

# Konfigurasi Zone K14.com sebagai Slave
cat > /etc/bind/named.conf.local << EOF
zone "K14.com" {
    type slave;
    file "/var/cache/bind/K14.com";
    masters { 192.218.3.4; };  # IP Erendis (Master)
};
EOF

# Restart BIND9
service bind9 restart
service bind9 status

echo "DNS Slave configuration completed on Amdir"
echo "Waiting for zone transfer from Erendis..."
sleep 5

# Check if zone transfer successful
if [ -f /var/cache/bind/K14.com ]; then
    echo "Zone transfer successful!"
    cat /var/cache/bind/K14.com
else
    echo "Zone transfer pending or failed. Check logs: tail -f /var/log/syslog"
fi

# Test DNS resolution
echo "Testing DNS resolution..."
dig @localhost palantir.K14.com
dig @localhost ns1.K14.com
dig @localhost ns2.K14.com
