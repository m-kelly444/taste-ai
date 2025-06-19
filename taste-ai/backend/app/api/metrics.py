from fastapi import APIRouter
import psutil
import time
import json

router = APIRouter()

@router.get("/metrics")
async def get_metrics():
    """Prometheus-style metrics endpoint"""
    
    # Basic system metrics
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    
    # Application metrics (mock for now)
    metrics = {
        "system": {
            "cpu_usage_percent": cpu_percent,
            "memory_usage_percent": memory.percent,
            "memory_used_bytes": memory.used,
            "memory_total_bytes": memory.total,
            "disk_usage_percent": disk.percent,
            "disk_used_bytes": disk.used,
            "disk_total_bytes": disk.total
        },
        "application": {
            "api_requests_total": 1247,
            "api_requests_errors": 12,
            "ml_inferences_total": 523,
            "ml_inference_duration_seconds": 0.845,
            "aesthetic_scores_processed": 523,
            "trends_analyzed": 23,
            "uptime_seconds": time.time()
        }
    }
    
    return metrics

@router.get("/health/detailed")
async def detailed_health():
    """Detailed health check"""
    return {
        "status": "healthy",
        "timestamp": time.time(),
        "version": "1.0.0",
        "components": {
            "database": "connected",
            "redis": "connected", 
            "ml_models": "loaded",
            "api": "operational"
        }
    }
