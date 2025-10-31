#!/bin/bash

# Script untuk Nomor 2
# Bagian 1: Install dan konfigurasi di ALDARION (DHCP Server)
# IP: 192.218.4.3

echo "Installing DHCP Server on Aldarion..."

# Install ISC DHCP Server
apt-get update
apt-get install isc-dhcp-server -y

# Backup konfigurasi default
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup
cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.backup

# Konfigurasi interface DHCP Server
cat > /etc/default/isc-dhcp-server << EOF
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

# Konfigurasi DHCP Server
cat > /etc/dhcp/dhcpd.conf << EOF
# DHCP Server Configuration for K14
ddns-update-style none;
option domain-name "K14.com";
option domain-name-servers 192.218.3.4;  # Erendis (DNS Master)
default-lease-time 1800;  # 30 menit = 1800 detik
max-lease-time 3600;      # 1 jam = 3600 detik

# Subnet untuk Durin eth1 (Switch1) - Keluarga Manusia
subnet 192.218.1.0 netmask 255.255.255.0 {
    range 192.218.1.6 192.218.1.34;
    range 192.218.1.68 192.218.1.94;
    option routers 192.218.1.1;  # Gateway ke Durin
    option broadcast-address 192.218.1.255;
    default-lease-time 1800;  # 30 menit untuk Manusia
    max-lease-time 3600;
}

# Subnet untuk Durin eth2 (Switch2) - Keluarga Peri
subnet 192.218.2.0 netmask 255.255.255.0 {
    range 192.218.2.35 192.218.2.67;
    range 192.218.2.96 192.218.2.121;
    option routers 192.218.2.1;  # Gateway ke Durin
    option broadcast-address 192.218.2.255;
    default-lease-time 600;   # 10 menit (seperenam jam) untuk Peri
    max-lease-time 3600;
}

# Subnet untuk Durin eth3 (Switch3) - Khamul Fixed Address
subnet 192.218.3.0 netmask 255.255.255.0 {
    option routers 192.218.3.1;
    option broadcast-address 192.218.3.255;
}

# Subnet untuk Durin eth4 (Switch4) - Network Aldarion
subnet 192.218.4.0 netmask 255.255.255.0 {
    option routers 192.218.4.1;
    option broadcast-address 192.218.4.255;
}

# Fixed Address untuk Khamul
host Khamul {
    hardware ethernet [GANTI_DENGAN_MAC_ADDRESS_KHAMUL];
    fixed-address 192.218.3.95;
}
EOF

# Restart DHCP Server
service isc-dhcp-server restart
service isc-dhcp-server status

echo "DHCP Server configuration completed on Aldarion"
echo "Remember to get Khamul's MAC address and update the configuration"
echo "Use: ip link show eth0 on Khamul to get MAC address"
