#!/bin/bash
echo "🛑 Stopping TASTE.AI services..."

if [ -f "backend.pid" ]; then
    echo "Stopping backend (PID: $(cat backend.pid))"
    kill $(cat backend.pid) 2>/dev/null || true
    rm -f backend.pid
fi

if [ -f "frontend.pid" ]; then
    echo "Stopping frontend (PID: $(cat frontend.pid))"
    kill $(cat frontend.pid) 2>/dev/null || true
    rm -f frontend.pid
fi

echo "Stopping Docker containers..."
docker-compose down

echo "✅ All services stopped"
