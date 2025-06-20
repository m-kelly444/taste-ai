#!/bin/bash
echo "⚡ Elite Performance Optimization..."

# Clean Docker
docker system prune -f

# Optimize Redis
docker exec $(docker ps -qf "name=redis") redis-cli config set maxmemory-policy allkeys-lru
docker exec $(docker ps -qf "name=redis") redis-cli config set save ""

# Set CPU priorities
for container in $(docker ps -q); do
    docker update --cpus="0.5" --memory="256m" $container 2>/dev/null || true
done

echo "✅ Elite optimization complete"
