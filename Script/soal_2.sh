apt update
apt install isc-dhcp-server -y

nano /etc/dhcp/dhcpd.conf
```
default-lease-time 1800;     
max-lease-time 3600;         
authoritative;

# Subnet Keluarga Manusia (10.78.1.0/24)
subnet 10.78.1.0 netmask 255.255.255.0 {
    range 10.78.1.6 10.78.1.34;
    range 10.78.1.68 10.78.1.94;
    option routers 10.78.1.1;
    option broadcast-address 10.78.1.255;
    option domain-name-servers 10.78.3.2;  # DNS utama (Erendis)
}

# Subnet Keluarga Peri (10.78.2.0/24)
subnet 10.78.2.0 netmask 255.255.255.0 {
    range 10.78.2.35 10.78.2.67;
    range 10.78.2.96 10.78.2.121;
    option routers 10.78.2.1;
    option broadcast-address 10.78.2.255;
    option domain-name-servers 10.78.3.2;
}

# Subnet Keluarga Dwarf (10.78.3.0/24)
subnet 10.78.3.0 netmask 255.255.255.0 {
    range 10.78.3.20 10.78.3.50;
    option routers 10.78.3.1;
    option broadcast-address 10.78.3.255;
    option domain-name-servers 10.78.3.2;
}

# Subnet Database (10.78.4.0/24)
subnet 10.78.4.0 netmask 255.255.255.0 {
    range 10.78.4.10 10.78.4.30;
    option routers 10.78.4.1;
    option broadcast-address 10.78.4.255;
    option domain-name-servers 10.78.3.2;
}

# Subnet Forwarder (10.78.5.0/24)
subnet 10.78.5.0 netmask 255.255.255.0 {
    range 10.78.5.10 10.78.5.30;
    option routers 10.78.5.1;
    option broadcast-address 10.78.5.255;
    option domain-name-servers 10.78.3.2;
}

# Host statis contoh
host khamul {
    hardware ethernet 02:69:78:43:95:01;
    fixed-address 10.78.3.95;
}
```

nano /etc/default/isc-dhcp-server
```
INTERFACESv4="eth0"
```
systemctl restart isc-dhcp-server
systemctl enable isc-dhcp-server

# Cek status
systemctl status isc-dhcp-server --no-pager | head -n 10

# Pastikan interfacenya diset ke DHCP:

auto eth0
iface eth0 inet dhcp

# Jalankan perintah:

# check ip
ip a

