#!/bin/bash

echo "💾 TASTE.AI - Database Backup"

BACKUP_DIR="backups/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

echo "🗄️ Backing up PostgreSQL..."
docker exec taste-ai-db-1 pg_dump -U user tasteai | gzip > "$BACKUP_DIR/postgres_$(date +%H%M%S).sql.gz"

echo "🔴 Backing up Redis..."
docker exec taste-ai-redis-1 redis-cli BGSAVE
docker cp taste-ai-redis-1:/data/dump.rdb "$BACKUP_DIR/redis_$(date +%H%M%S).rdb"

echo "📁 Backing up application data..."
tar -czf "$BACKUP_DIR/app_data_$(date +%H%M%S).tar.gz" test-data/ test-images/ || true

echo "✅ Backup completed: $BACKUP_DIR"

# Clean up backups older than 30 days
find backups/ -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
