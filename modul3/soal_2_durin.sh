#!/bin/bash

# Script untuk Nomor 2 - Bagian 2
# Install dan konfigurasi DHCP Relay di DURIN (Router)

echo "Installing DHCP Relay on Durin..."

# Install DHCP Relay
apt-get update
apt-get install isc-dhcp-relay -y

# Backup konfigurasi default
cp /etc/default/isc-dhcp-relay /etc/default/isc-dhcp-relay.backup

# Konfigurasi DHCP Relay
cat > /etc/default/isc-dhcp-relay << EOF
# DHCP Relay configuration for Durin
SERVERS="192.218.4.3"  # IP Aldarion (DHCP Server)
INTERFACES="eth1 eth2 eth3 eth4"  # Interface yang akan relay
OPTIONS=""
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf
sysctl -p

# Restart DHCP Relay
service isc-dhcp-relay restart
service isc-dhcp-relay status

echo "DHCP Relay configuration completed on Durin"
echo "DHCP Relay will forward requests to Aldarion at 192.218.4.3"
