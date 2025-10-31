#!/bin/bash

# Script untuk Nomor 5
# Menambahkan WWW alias, Reverse PTR, dan TXT records di ERENDIS (DNS Master)
# IP: 192.218.3.4

echo "Adding WWW alias, Reverse PTR, and TXT records on Erendis..."

# Update Zone File K14.com dengan alias www dan TXT records
cat > /etc/bind/zones/K14.com << EOF
\$TTL    604800
@       IN      SOA     ns1.K14.com. root.K14.com. (
                        2025103102      ; Serial (updated)
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
; Name servers
@       IN      NS      ns1.K14.com.
@       IN      NS      ns2.K14.com.

; Name server A records
ns1     IN      A       192.218.3.4   ; Erendis
ns2     IN      A       192.218.3.3   ; Amdir

; WWW Alias untuk domain utama
www     IN      CNAME   K14.com.
@       IN      A       192.218.3.4

; Host A records
palantir        IN      A       192.218.4.5
elros           IN      A       192.218.1.35
pharazon        IN      A       192.218.2.36
elendil         IN      A       192.218.1.37
isildur         IN      A       192.218.1.38
anarion         IN      A       192.218.1.39
galadriel       IN      A       192.218.2.3
celeborn        IN      A       192.218.2.4
oropher         IN      A       192.218.2.5

; TXT Records - Pesan Rahasia
@       IN      TXT     "Cincin Sauron" "192.218.1.35"
@       IN      TXT     "Aliansi Terakhir" "192.218.2.36"
EOF

# Konfigurasi Reverse DNS Zone untuk subnet 3 (Erendis & Amdir)
cat >> /etc/bind/named.conf.local << EOF

zone "3.218.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/192.218.3.rev";
    allow-transfer { 192.218.3.3; };
    also-notify { 192.218.3.3; };
};
EOF

# Buat Reverse Zone File
cat > /etc/bind/zones/192.218.3.rev << EOF
\$TTL    604800
@       IN      SOA     ns1.K14.com. root.K14.com. (
                        2025103101      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
; Name servers
@       IN      NS      ns1.K14.com.
@       IN      NS      ns2.K14.com.

; PTR Records
4       IN      PTR     ns1.K14.com.    ; Erendis 192.218.3.4
3       IN      PTR     ns2.K14.com.    ; Amdir 192.218.3.3
EOF

# Set permissions
chmod 644 /etc/bind/zones/K14.com
chmod 644 /etc/bind/zones/192.218.3.rev
chown bind:bind /etc/bind/zones/*

# Check configuration
named-checkconf
named-checkzone K14.com /etc/bind/zones/K14.com
named-checkzone 3.218.192.in-addr.arpa /etc/bind/zones/192.218.3.rev

# Restart BIND9
service bind9 restart
service bind9 status

echo "WWW alias, Reverse PTR, and TXT records added successfully"
echo "Testing configurations..."

# Test WWW alias
echo "Testing www.K14.com alias:"
dig @localhost www.K14.com

# Test TXT records
echo "Testing TXT records:"
dig @localhost K14.com TXT

# Test Reverse DNS
echo "Testing Reverse DNS for Erendis:"
dig @localhost -x 192.218.3.4

echo "Testing Reverse DNS for Amdir:"
dig @localhost -x 192.218.3.3

echo "Amdir will automatically sync these changes via zone transfer"
