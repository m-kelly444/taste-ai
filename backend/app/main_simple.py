from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import os
import sys

app = FastAPI(
    title="TASTE.AI",
    description="Aesthetic Intelligence Platform",
    version="1.0.0",
    docs_url="/api/docs"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {
        "message": "TASTE.AI - Aesthetic Intelligence Platform", 
        "status": "running",
        "version": "1.0.0"
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy", 
        "version": "1.0.0"
    }

@app.post("/api/v1/auth/login")
async def login(credentials: dict):
    username = credentials.get("username")
    password = credentials.get("password")
    
    if username == "admin" and password == "password":
        return {
            "access_token": "test-token-12345",
            "token_type": "bearer"
        }
    else:
        raise HTTPException(status_code=401, detail="Invalid credentials")

@app.get("/api/v1/trends/current")
async def get_current_trends():
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

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
