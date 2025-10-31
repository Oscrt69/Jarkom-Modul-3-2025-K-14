#!/bin/bash

# Script untuk Nomor 9
# Testing Laravel Workers dari Client
# Jalankan script ini di CLIENT (Miriel, Gilgalad, Celebrimbor, atau Amandil)

echo "Testing Laravel Workers from Client..."

# Install lynx and curl if not available
apt-get update
apt-get install -y lynx curl

echo "==================================="
echo "Testing Elendil (Port 8001)"
echo "==================================="
echo "Main page test:"
lynx -dump http://elendil.k14.com:8001

echo ""
echo "API test:"
curl http://elendil.k14.com:8001/api/airing
echo ""
echo ""

echo "==================================="
echo "Testing Isildur (Port 8002)"
echo "==================================="
echo "Main page test:"
lynx -dump http://isildur.k14.com:8002

echo ""
echo "API test:"
curl http://isildur.k14.com:8002/api/airing
echo ""
echo ""

echo "==================================="
echo "Testing Anarion (Port 8003)"
echo "==================================="
echo "Main page test:"
lynx -dump http://anarion.k14.com:8003

echo ""
echo "API test:"
curl http://anarion.k14.com:8003/api/airing
echo ""
echo ""

echo "Testing completed!"
echo "If you see JSON data from /api/airing, the workers are functioning correctly"
echo "and can connect to Palantir database"
