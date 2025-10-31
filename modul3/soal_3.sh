#!/bin/bash

# Script untuk Nomor 3
# Konfigurasi DNS Forwarder di MINASTIR

echo "Installing DNS Forwarder (BIND9) on Minastir..."

# Install BIND9
apt-get update
apt-get install bind9 bind9utils dnsutils -y

# Backup konfigurasi default
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup

# Konfigurasi BIND9 sebagai DNS Forwarder
cat > /etc/bind/named.conf.options << EOF
options {
    directory "/var/cache/bind";

    # Forwarder ke Valinor/Internet
    forwarders {
        192.168.122.1;
    };

    # Allow queries from any host
    allow-query { any; };

    # Listen on all interfaces
    listen-on { any; };
    listen-on-v6 { none; };

    # Forward only mode
    forward only;

    # DNSSEC validation
    dnssec-validation auto;

    auth-nxdomain no;
};
EOF

# Restart BIND9
service bind9 restart
service bind9 status

echo "DNS Forwarder configuration completed on Minastir"
echo "Testing DNS forwarding..."

# Test DNS
dig @localhost google.com

echo "All nodes (except Durin) should use Minastir as their DNS forwarder"
echo "Configure other nodes to use nameserver pointing to Minastir's IP"
