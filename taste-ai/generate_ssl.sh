#!/bin/bash

echo "🔒 Generating SSL Certificates"

mkdir -p deployment/ssl/certs

# Generate self-signed certificate for development
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout deployment/ssl/certs/tasteai.key \
    -out deployment/ssl/certs/tasteai.crt \
    -subj "/C=US/ST=NY/L=New York/O=TASTE.AI/CN=tasteai.com"

echo "✅ SSL certificates generated"
echo "⚠️  For production, replace with certificates from a trusted CA"
