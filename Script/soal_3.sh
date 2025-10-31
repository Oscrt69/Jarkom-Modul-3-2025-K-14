FORWARD_DNS="192.168.122.1"
BIND_CONF="/etc/bind/named.conf.options"
LOG_FILE="/var/log/named_queries.log"

apt update 
apt install bind9 bind9utils bind9-dnsutils -y 

nano /etc/bind/named.conf.options 
```
options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;
    };

    allow-query { any; };
    listen-on { any; };
    recursion yes;
};

logging {
    channel query_log {
        file "/var/log/named_queries.log" versions 3 size 5m;
        severity info;
        print-time yes;
    };

    category queries { query_log; };
};
```

rm -f /etc/resolv.conf
grep -qxF "net.ipv4.ip_forward=1" /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

service bind9 restart
sleep 1
systemctl enable bind9 >/dev/null

apt install -y dnsutils >/dev/null
dig google.com @127.0.0.1 +short | head -n 2

if [ $? -eq 0 ]; then
    echo "Minastir berhasil diatur sebagai DNS Forwarder!"
    echo "   - IP Server  : 10.78.5.2"
    echo "   - Gateway    : 10.78.5.1 (Durin)"
    echo "   - Forwarders : 192.168.122.1"
    echo "   - Log Query  : /var/log/named_queries.log"
else
    echo "Tes resolusi DNS gagal. Periksa konfigurasi jaringan atau IP forwarder."
fi
