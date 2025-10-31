#!/bin/bash

# Script untuk Nomor 4
# Konfigurasi DNS Master di ERENDIS
# IP: 192.218.3.4

echo "Installing DNS Master (BIND9) on Erendis..."

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

    # Forwarder (optional, bisa ke Minastir atau Internet)
    forwarders {
        192.168.122.1;
    };

    allow-transfer { 192.218.3.3; };  # IP Amdir (DNS Slave)
    also-notify { 192.218.3.3; };

    dnssec-validation auto;
    auth-nxdomain no;
};
EOF

# Konfigurasi Zone K14.com
cat > /etc/bind/named.conf#!/bin/bash

# Script untuk Nomor 4
# Konfigurasi DNS Master di ERENDIS
# IP: 192.218.3.4

echo "Installing DNS Master (BIND9) on Erendis..."

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

    # Forwarder (optional, bisa ke Minastir atau Internet)
    forwarders {
        192.168.122.1;
    };

    allow-transfer { 192.218.3.3; };  # IP Amdir (DNS Slave)
    also-notify { 192.218.3.3; };

    dnssec-validation auto;
    auth-nxdomain no;
};
EOF

# Konfigurasi Zone K14.com
cat > /etc/bind/named.conf.local << EOF
zone "K14.com" {
    type master;
    file "/etc/bind/zones/K14.com";
    allow-transfer { 192.218.3.3; };  # Amdir
    also-notify { 192.218.3.3; };
};
EOF

# Buat direktori zones
mkdir -p /etc/bind/zones

# Konfigurasi Zone File untuk K14.com
cat > /etc/bind/zones/K14.com << EOF
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

; Name server A records
ns1     IN      A       192.218.3.4   ; Erendis
ns2     IN      A       192.218.3.3   ; Amdir

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
EOF

# Set permissions
chmod 644 /etc/bind/zones/K14.com
chown bind:bind /etc/bind/zones/K14.com

# Check configuration
named-checkconf
named-checkzone K14.com /etc/bind/zones/K14.com

# Restart BIND9
service bind9 restart
service bind9 status

echo "DNS Master configuration completed on Erendis"
echo "Testing DNS resolution..."
dig @localhost palantir.K14.com
dig @localhost ns1.K14.com
dig @localhost ns2.K14.com.local << EOF
zone "K14.com" {
    type master;
    file "/etc/bind/zones/K14.com";
    allow-transfer { 192.218.3.3; };  # Amdir
    also-notify { 192.218.3.3; };
};
EOF

# Buat direktori zones
mkdir -p /etc/bind/zones

# Konfigurasi Zone File untuk K14.com
cat > /etc/bind/zones/K14.com << EOF
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

; Name server A records
ns1     IN      A       192.218.3.4   ; Erendis
ns2     IN      A       192.218.3.3   ; Amdir

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
EOF

# Set permissions
chmod 644 /etc/bind/zones/K14.com
chown bind:bind /etc/bind/zones/K14.com

# Check configuration
named-checkconf
named-checkzone K14.com /etc/bind/zones/K14.com

# Restart BIND9
service bind9 restart
service bind9 status

echo "DNS Master configuration completed on Erendis"
echo "Testing DNS resolution..."
dig @localhost palantir.K14.com
dig @localhost ns1.K14.com
dig @localhost ns2.K14.com
