Durin 

```
nano /etc/network/interfaces
```

auto eth0
iface eth0 inet dhcp
    dns-nameservers 192.168.122.1
    up /root/router_startup.sh

auto eth1
iface eth1 inet static
    address 10.78.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.78.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.78.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 10.78.4.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 10.78.5.1
    netmask 255.255.255.0

nano /root/router_startup.sh

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.78.0.0/16

iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth3 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth4 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth5 -j ACCEPT

iptables -A OUTPUT -o eth0 -j DROP

chmod +x /root/router_startup.sh

# ---------- SUBNET 10.78.1.0/24 ----------
# Elendil
auto eth0
iface eth0 inet static
    address 10.78.1.2
    netmask 255.255.255.0
    gateway 10.78.1.1
    dns-nameservers 192.168.122.1

# Isildur
auto eth0
iface eth0 inet static
    address 10.78.1.3
    netmask 255.255.255.0
    gateway 10.78.1.1
    dns-nameservers 192.168.122.1

# Anarion
auto eth0
iface eth0 inet static
    address 10.78.1.4
    netmask 255.255.255.0
    gateway 10.78.1.1
    dns-nameservers 192.168.122.1

# Miriel
auto eth0
iface eth0 inet static
    address 10.78.1.5
    netmask 255.255.255.0
    gateway 10.78.1.1
    dns-nameservers 192.168.122.1

# Amandil (DHCP)
auto eth0
iface eth0 inet dhcp
    dns-nameservers 192.168.122.1

# Elros
auto eth0
iface eth0 inet static
    address 10.78.1.7
    netmask 255.255.255.0
    gateway 10.78.1.1
    dns-nameservers 192.168.122.1

# ---------- SUBNET 10.78.2.0/24 ----------
# Gilgalad (DHCP)
auto eth0
iface eth0 inet dhcp
    dns-nameservers 192.168.122.1

# Celebrimbor
auto eth0
iface eth0 inet static
    address 10.78.2.3
    netmask 255.255.255.0
    gateway 10.78.2.1
    dns-nameservers 192.168.122.1

# Pharazon
auto eth0
iface eth0 inet static
    address 10.78.2.4
    netmask 255.255.255.0
    gateway 10.78.2.1
    dns-nameservers 192.168.122.1

# Galadriel
auto eth0
iface eth0 inet static
    address 10.78.2.5
    netmask 255.255.255.0
    gateway 10.78.2.1
    dns-nameservers 192.168.122.1

# Celeborn
auto eth0
iface eth0 inet static
    address 10.78.2.6
    netmask 255.255.255.0
    gateway 10.78.2.1
    dns-nameservers 192.168.122.1

# Oropher
auto eth0
iface eth0 inet static
    address 10.78.2.7
    netmask 255.255.255.0
    gateway 10.78.2.1
    dns-nameservers 192.168.122.1

# ---------- SUBNET 10.78.3.0/24 ----------
# Khamul
auto eth0
iface eth0 inet static
    address 10.78.3.2
    netmask 255.255.255.0
    gateway 10.78.3.1
    dns-nameservers 192.168.122.1

# Erendis
auto eth0
iface eth0 inet static
    address 10.78.3.3
    netmask 255.255.255.0
    gateway 10.78.3.1
    dns-nameservers 192.168.122.1

# Amdir
auto eth0
iface eth0 inet static
    address 10.78.3.4
    netmask 255.255.255.0
    gateway 10.78.3.1
    dns-nameservers 192.168.122.1

# ---------- SUBNET 10.78.4.0/24 ----------
# Aldarion
auto eth0
iface eth0 inet static
    address 10.78.4.2
    netmask 255.255.255.0
    gateway 10.78.4.1
    dns-nameservers 192.168.122.1

# Palantir
auto eth0
iface eth0 inet static
    address 10.78.4.3
    netmask 255.255.255.0
    gateway 10.78.4.1
    dns-nameservers 192.168.122.1

# Narvi
auto eth0
iface eth0 inet static
    address 10.78.4.4
    netmask 255.255.255.0
    gateway 10.78.4.1
    dns-nameservers 192.168.122.1

# ---------- SUBNET 10.78.5.0/24 ----------
# Minastir
auto eth0
iface eth0 inet static
    address 10.78.5.2
    netmask 255.255.255.0
    gateway 10.78.5.1
    dns-nameservers 192.168.122.1
