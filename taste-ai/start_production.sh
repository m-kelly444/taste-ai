#!/bin/bash
echo "Starting TASTE.AI production system..."

docker-compose -f docker-compose.optimized.yml down
docker-compose -f docker-compose.optimized.yml build --no-cache
docker-compose -f docker-compose.optimized.yml up -d

echo "Waiting for services to start..."
sleep 10

echo "Testing deployment..."
curl -f http://localhost:8001/health && echo "✅ Backend healthy"
curl -f http://localhost:3002 && echo "✅ Frontend accessible"

echo "🎯 TASTE.AI production deployment complete!"
echo "Frontend: http://localhost:3002"
echo "Backend:  http://localhost:8001"
echo "API Docs: http://localhost:8001/api/docs"
