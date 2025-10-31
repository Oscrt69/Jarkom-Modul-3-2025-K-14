#!/bin/bash
ip addr flush dev eth0
ip addr add 192.218.1.37/24 dev eth0
ip link set eth0 up
ip route add default via 192.218.1.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update
ping -c 3 google.com
