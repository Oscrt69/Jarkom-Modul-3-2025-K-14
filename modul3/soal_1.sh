#!/bin/bash
# ============================================
# SOAL 1 (Improved) - DURIN (Router)
# K14 - Prefix IP: 192.218
# ============================================

echo "--- Soal 1: Konfigurasi Durin (Router) ---"

# 1. Konfigurasi eth0 (Koneksi ke NAT1/Internet)
# -------------------------------------------------
echo "[1] Konfigurasi eth0 (Koneksi ke NAT1/Internet)..."
# Pastikan interface UP
ip link set eth0 up

# Hentikan dhclient lama & rilis lease (membuat lebih robust)
echo "   Melepaskan lease DHCP lama (jika ada)..."
dhclient -r eth0 >/dev/null 2>&1
killall dhclient >/dev/null 2>&1

# Minta IP baru
echo "   Meminta IP baru dari NAT1 via DHCP..."
dhclient eth0

# Verifikasi!
if ! ip addr show eth0 | grep -q "inet "; then
    echo "   [GAGAL] eth0 tidak mendapatkan IP. Cek koneksi NAT1 di GNS3."
    exit 1
fi
echo "   [OK] eth0 mendapatkan IP:"
ip addr show eth0 | grep "inet " | xargs

# 2. Konfigurasi Interface Internal
# -------------------------------------------------
echo "[2] Konfigurasi interface internal (eth1-eth5)..."
# Flush IP lama agar skrip aman dijalankan ulang
ip addr flush dev eth1 >/dev/null 2>&1
ip addr add 192.218.1.1/24 dev eth1 && ip link set eth1 up
echo "   - eth1: 192.218.1.1/24 (Manusia)"

ip addr flush dev eth2 >/dev/null 2>&1
ip addr add 192.218.2.1/24 dev eth2 && ip link set eth2 up
echo "   - eth2: 192.218.2.1/24 (Peri)"

ip addr flush dev eth3 >/dev/null 2>&1
ip addr add 192.218.3.1/24 dev eth3 && ip link set eth3 up
echo "   - eth3: 192.218.3.1/24 (Khamul, dll)"

ip addr flush dev eth4 >/dev/null 2>&1
ip addr add 192.218.4.1/24 dev eth4 && ip link set eth4 up
echo "   - eth4: 192.218.4.1/24 (Server)"

ip addr flush dev eth5 >/dev/null 2>&1
ip addr add 192.218.5.1/24 dev eth5 && ip link set eth5 up
echo "   - eth5: 192.218.5.1/24 (Minastir)"

# 3. Konfigurasi IP Forwarding & NAT (iptables)
# -------------------------------------------------
echo "[3] Konfigurasi IP Forwarding dan NAT (iptables)..."
# Aktifkan IP Forwarding
sysctl -w net.ipv4.ip_forward=1 >/dev/null

# Flush rules lama (NAT table dan FILTER FORWARD chain)
iptables -t nat -F
iptables -F FORWARD

# Aturan NAT (Masquerade)
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
echo "   - Aturan NAT Masquerade di eth0 diset."

# Aturan Forwarding (FILTER table)
# Izinkan koneksi yang sudah ada/terkait
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
# Izinkan koneksi BARU dari internal (semua eth1-5) ke eksternal (eth0)
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT
echo "   - Aturan FORWARD untuk eth1-5 -> eth0 diset."

# 4. Konfigurasi DNS & Update
# -------------------------------------------------
echo "[4] Konfigurasi DNS Resolver sementara..."
# Sesuai soal, gunakan 192.168.122.1 untuk instalasi awal [cite: 147]
echo 'nameserver 192.168.122.1' > /etc/resolv.conf
echo "   - /etc/resolv.conf diatur ke 192.168.122.1."

echo "[5] Menjalankan 'apt-get update' (Instruksi Awal)..."
apt-get update

# 5. Verifikasi Akhir
# -------------------------------------------------
echo ""
echo "============================================="
echo "--- Konfigurasi Durin Selesai ---"
echo "============================================="
echo "Tes koneksi internet ke google.com..."
if ping -c 3 google.com; then
    echo "[SUKSES] Durin terhubung ke internet."
else
    echo "[GAGAL] Durin TIDAK terhubung ke internet."
fi
