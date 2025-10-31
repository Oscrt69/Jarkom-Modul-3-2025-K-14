#!/bin/bash

# Script untuk Nomor 11 - Bagian 2
# Menambahkan weight pada Load Balancer Elros
# Jalankan di ELROS

echo "Adding weight to Load Balancer configuration..."

# Configure Nginx Load Balancer dengan weight
cat > /etc/nginx/sites-available/elros << EOF
upstream kesatria_numenor {
    server 192.218.1.37:8001 weight=3;  # Elendil (lebih kuat)
    server 192.218.1.38:8002 weight=2;  # Isildur
    server 192.218.1.39:8003 weight=1;  # Anarion
}

server {
    listen 80;
    server_name elros.k14.com;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_log /var/log/nginx/elros_error.log;
    access_log /var/log/nginx/elros_access.log;
}
EOF

# Test and reload Nginx
nginx -t
service nginx reload

echo "Weight configuration applied:"
echo "  - Elendil: weight=3 (50% traffic)"
echo "  - Isildur: weight=2 (33% traffic)"
echo "  - Anarion: weight=1 (17% traffic)"
echo ""
echo "Now run benchmark again from client to compare results"
