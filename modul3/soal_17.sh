#!/bin/bash

# Script untuk Nomor 17
# Benchmark dan Failover testing untuk Pharazon
# Jalankan dari CLIENT

echo "Installing Apache Bench and testing tools..."
apt-get update
apt-get install -y apache2-utils

echo "==================================="
echo "BENCHMARK TEST WITH AUTHENTICATION"
echo "==================================="
echo "Running benchmark: 1000 requests, 50 concurrent"
ab -n 1000 -c 50 -A noldor:silvan http://pharazon.k14.com/

echo ""
echo "==================================="
echo "BENCHMARK RESULTS RECORDED"
echo "==================================="
echo ""
echo "Now simulating failover scenario..."
echo ""
echo "Instructions for failover test:"
echo "1. SSH to Galadriel and run: service nginx stop"
echo "2. Then run this test again:"
echo ""
echo "   ab -n 500 -c 25 -A noldor:silvan http://pharazon.k14.com/"
echo ""
echo "3. Check Pharazon logs: ssh to Pharazon and run:"
echo "   tail -f /var/log/nginx/pharazon_access.log"
echo "   tail -f /var/log/nginx/pharazon_error.log"
echo ""
echo "4. After test, restart Galadriel: service nginx start"
echo ""
echo "Expected behavior: Pharazon should automatically route traffic"
echo "to remaining workers (Celeborn and Oropher) when Galadriel is down"
