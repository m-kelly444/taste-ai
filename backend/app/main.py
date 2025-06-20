from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(
    title="TASTE.AI Advanced",
    description="Advanced Aesthetic Intelligence Platform",
    version="2.0.0",
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

@app.get("/")
async def root():
    return {
        "message": "TASTE.AI Advanced - Aesthetic Intelligence Platform", 
        "status": "running",
        "version": "2.0.0",
        "features": [
            "Advanced aesthetic analysis",
            "Chris Burch specialization", 
            "Trend forecasting",
            "Commercial appeal scoring"
        ],
        "docs": "/api/docs"
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy", 
        "version": "2.0.0"
    }

@app.post("/api/v1/auth/login")
async def login(credentials: dict):
    username = credentials.get("username")
    password = credentials.get("password")
    
    if username == "admin" and password == "password":
        return {
            "access_token": "advanced-taste-ai-token-v2",
            "token_type": "bearer",
            "user_type": "premium"
        }
    elif username == "chris" and password == "burch":
        return {
            "access_token": "chris-burch-exclusive-token",
            "token_type": "bearer", 
            "user_type": "founder"
        }
    else:
        raise HTTPException(status_code=401, detail="Invalid credentials")

@app.get("/api/v1/trends/current")
async def get_current_trends():
    return {
        "trends": [
            {
                "name": "Quiet Luxury",
                "score": 0.94,
                "category": "style",
                "momentum": "rising",
                "burch_alignment": 0.91,
                "commercial_potential": 0.89,
                "timeline": "6-12 months",
                "description": "Understated elegance without obvious branding"
            },
            {
                "name": "Sustainable Materials",
                "score": 0.87,
                "category": "materials", 
                "momentum": "rising",
                "burch_alignment": 0.82,
                "commercial_potential": 0.85,
                "timeline": "12+ months",
                "description": "Eco-conscious luxury materials and production"
            }
        ],
        "market_insights": {
            "luxury_growth": 0.12,
            "digital_influence": 0.78,
            "sustainability_importance": 0.85
        }
    }

@app.get("/metrics")
async def get_metrics():
    return {
        "system": {
            "cpu_usage_percent": 18.7,
            "memory_usage_percent": 72.3,
            "status": "optimal"
        },
        "application": {
            "api_requests_total": 2847,
            "ml_inferences_total": 1234,
            "uptime_seconds": 86400
        }
    }

# Include aesthetic router
try:
    from app.api import aesthetic
    app.include_router(aesthetic.router, prefix="/api/v1/aesthetic", tags=["aesthetic"])
    print("✅ Aesthetic router loaded")
except Exception as e:
    print(f"⚠️  Could not load aesthetic router: {e}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
