#!/bin/bash
echo "🔄 Restarting TASTE.AI system..."
./stop_services.sh
sleep 3
./fix_and_setup.sh
