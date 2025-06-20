from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import redis
import json
import numpy as np
from PIL import Image
import io
import random

app = FastAPI(title="TASTE.AI Elite", version="3.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Elite Redis connection
r = redis.Redis(host='redis', port=6379, decode_responses=True)

class EliteAestheticEngine:
    def __init__(self):
        self.burch_weights = {
            'sophistication': 0.95, 'minimalism': 0.9, 'luxury': 0.85,
            'timeless': 0.8, 'elegance': 0.88, 'balance': 0.92
        }
    
    def analyze(self, image):
        img_array = np.array(image.convert('RGB'))
        
        # Elite aesthetic calculations
        brightness = np.mean(img_array) / 255.0
        color_variance = np.var(img_array)
        edge_density = len(np.where(np.diff(img_array.mean(axis=2)) > 20)[0])
        
        # Burch-specific scoring
        sophistication = min(1.0, (brightness * 0.6 + (1 - color_variance/10000) * 0.4))
        luxury_score = min(1.0, edge_density / 1000 + sophistication * 0.3)
        
        aesthetic_score = (
            sophistication * self.burch_weights['sophistication'] * 0.3 +
            luxury_score * self.burch_weights['luxury'] * 0.25 +
            brightness * self.burch_weights['balance'] * 0.45
        )
        
        return {
            'aesthetic_score': float(aesthetic_score),
            'sophistication': float(sophistication),
            'luxury_appeal': float(luxury_score),
            'burch_alignment': float(aesthetic_score * 0.95),
            'confidence': 0.92
        }

engine = EliteAestheticEngine()

@app.get("/")
async def root():
    return {
        "service": "TASTE.AI Elite v3.0",
        "status": "operational",
        "features": ["aesthetic_analysis", "burch_specialization", "trend_prediction"]
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "version": "3.0"}

@app.post("/api/v1/aesthetic/score")
async def score_aesthetic(file: UploadFile = File(...)):
    if not file.content_type.startswith('image/'):
        raise HTTPException(400, "Invalid file type")
    
    try:
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        
        result = engine.analyze(image)
        
        # Cache result
        cache_key = f"score:{hash(image_data)}"
        r.setex(cache_key, 3600, json.dumps(result))
        
        return result
        
    except Exception as e:
        raise HTTPException(500, f"Analysis failed: {str(e)}")

@app.get("/api/v1/trends/current")
async def current_trends():
    return {
        "trends": [
            {"name": "Quiet Luxury", "score": 0.94, "momentum": "rising"},
            {"name": "Sustainable Materials", "score": 0.87, "momentum": "stable"},
            {"name": "Timeless Minimalism", "score": 0.91, "momentum": "rising"}
        ]
    }

@app.get("/metrics")
async def metrics():
    return {
        "version": "3.0",
        "uptime": "active",
        "cache_hits": r.dbsize(),
        "status": "elite"
    }
