#!/bin/bash

# Script untuk Nomor 6
# Update DHCP lease time di ALDARION
# IP: 192.218.4.3

echo "Updating DHCP lease time configuration on Aldarion..."

# Backup konfigurasi sebelumnya
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.backup.v2

# Update Konfigurasi DHCP Server dengan lease time yang benar
cat > /etc/dhcp/dhcpd.conf << EOF
# DHCP Server Configuration for K14
ddns-update-style none;
option domain-name "K14.com";
option domain-name-servers 192.218.3.4;  # Erendis (DNS Master)
default-lease-time 1800;  # Default 30 menit
max-lease-time 3600;      # Max 1 jam untuk semua

# Subnet untuk Durin eth1 (Switch1) - Keluarga Manusia
subnet 192.218.1.0 netmask 255.255.255.0 {
    range 192.218.1.6 192.218.1.34;
    range 192.218.1.68 192.218.1.94;
    option routers 192.218.1.1;
    option broadcast-address 192.218.1.255;
    default-lease-time 1800;  # 30 menit (setengah jam) untuk Manusia
    max-lease-time 3600;      # Max 1 jam
}

# Subnet untuk Durin eth2 (Switch2) - Keluarga Peri
subnet 192.218.2.0 netmask 255.255.255.0 {
    range 192.218.2.35 192.218.2.67;
    range 192.218.2.96 192.218.2.121;
    option routers 192.218.2.1;
    option broadcast-address 192.218.2.255;
    default-lease-time 600;   # 10 menit (1/6 jam = 60/6 = 10 menit) untuk Peri
    max-lease-time 3600;      # Max 1 jam
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

echo "DHCP lease time configuration updated successfully"
echo "Lease times:"
echo "- Keluarga Manusia (192.218.1.x): 30 menit (default), max 1 jam"
echo "- Keluarga Peri (192.218.2.x): 10 menit (default), max 1 jam"
echo "- Semua client: maksimal peminjaman 1 jam"

# Show current leases
echo "Current DHCP leases:"
cat /var/lib/dhcp/dhcpd.leases
