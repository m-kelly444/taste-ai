from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    from app.api import aesthetic, trends, auth, metrics
except ImportError as e:
    print(f"Warning: Could not import all modules: {e}")
    # Create minimal fallback modules
    from fastapi import APIRouter
    
    class FallbackAPI:
        def __init__(self):
            self.router = APIRouter()
            self.router.add_api_route("/", self.root, methods=["GET"])
        
        async def root(self):
            return {"message": "Fallback API active", "status": "limited"}
    
    aesthetic = trends = auth = metrics = FallbackAPI()

app = FastAPI(
    title="TASTE.AI",
    description="Aesthetic Intelligence Platform",
    version="1.0.0",
    docs_url="/api/docs"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3002", "http://localhost:3000", "*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Basic routes first
@app.get("/")
async def root():
    return {
        "message": "TASTE.AI - Aesthetic Intelligence Platform", 
        "status": "running",
        "version": "1.0.0",
        "docs": "/api/docs"
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy", 
        "version": "1.0.0",
        "timestamp": "2025-06-19T12:00:00Z"
    }

# Simple auth endpoint
@app.post("/api/v1/auth/login")
async def simple_login(credentials: dict):
    username = credentials.get("username")
    password = credentials.get("password")
    
    if username == "admin" and password == "password":
        return {
            "access_token": "simple-test-token-12345",
            "token_type": "bearer"
        }
    else:
        raise HTTPException(status_code=401, detail="Invalid credentials")

# Simple trends endpoint
@app.get("/api/v1/trends/current")
async def get_trends():
    return {
        "trends": [
            {
                "name": "Minimalist Luxury",
                "score": 0.89,
                "category": "fashion",
                "momentum": "rising"
            },
            {
                "name": "Earth Tones",
                "score": 0.76,
                "category": "color",
                "momentum": "stable"
            }
        ]
    }

# Simple metrics endpoint
@app.get("/metrics")
async def get_metrics():
    return {
        "system": {
            "cpu_usage_percent": 15.2,
            "memory_usage_percent": 68.5,
            "status": "healthy"
        },
        "application": {
            "api_requests_total": 156,
            "uptime_seconds": 3600
        }
    }

# Include routers with error handling
try:
    if hasattr(aesthetic, 'router'):
        app.include_router(aesthetic.router, prefix="/api/v1/aesthetic", tags=["aesthetic"])
    if hasattr(trends, 'router'):
        app.include_router(trends.router, prefix="/api/v1/trends", tags=["trends"])
    if hasattr(auth, 'router'):
        app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
    if hasattr(metrics, 'router'):
        app.include_router(metrics.router, tags=["metrics"])
except Exception as e:
    print(f"Warning: Could not include some routers: {e}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
