#!/bin/bash
echo "🔍 Verifying TASTE.AI Backend..."

if ! curl -s http://localhost:8001/health >/dev/null; then
    echo "❌ Backend not responding"
    exit 1
fi

echo "✅ Backend health check passed"

# Test auth
if curl -s -X POST http://localhost:8001/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "admin", "password": "password"}' | grep -q "access_token"; then
    echo "✅ Authentication working"
else
    echo "❌ Authentication failed"
fi

# Test trends
if curl -s http://localhost:8001/api/v1/trends/current | grep -q "trends"; then
    echo "✅ Trends API working"
else
    echo "❌ Trends API failed"
fi

echo "✅ Backend verification complete"
