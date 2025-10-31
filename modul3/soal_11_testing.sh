#!/bin/bash

# Script untuk Nomor 11
# Benchmark testing untuk Load Balancer Elros
# Jalankan dari CLIENT

echo "Installing Apache Bench..."
apt-get update
apt-get install -y apache2-utils htop

echo "==================================="
echo "SERANGAN AWAL: 100 requests, 10 concurrent"
echo "==================================="
ab -n 100 -c 10 http://elros.k14.com/api/airing

echo ""
echo "==================================="
echo "SERANGAN PENUH: 2000 requests, 100 concurrent"
echo "==================================="
ab -n 2000 -c 100 http://elros.k14.com/api/airing

echo ""
echo "Check Elros logs to see distribution:"
echo "ssh to Elros and run: tail -f /var/log/nginx/elros_access.log"
echo ""
echo "To add weight, modify /etc/nginx/sites-available/elros on Elros:"
echo ""
cat << 'EOF'
upstream kesatria_numenor {
    server 192.218.1.37:8001 weight=3;  # Elendil (lebih kuat)
    server 192.218.1.38:8002 weight=2;  # Isildur
    server 192.218.1.39:8003 weight=1;  # Anarion
}
EOF

echo ""
echo "Script untuk update weight ada di script_11b.sh - jalankan di Elros"
