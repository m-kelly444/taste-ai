from fastapi import APIRouter, Depends
from app.core.security import get_current_user
import random

router = APIRouter()

@router.get("/current")
async def get_current_trends(user = Depends(get_current_user)):
    return {
        "trends": [
            {
                "name": "Minimalist Luxury",
                "score": 0.89,
                "category": "fashion",
                "momentum": "rising",
                "peak_estimate": "3-6 months"
            },
            {
                "name": "Earth Tones",
                "score": 0.76,
                "category": "color",
                "momentum": "stable",
                "peak_estimate": "current"
            },
            {
                "name": "Oversized Silhouettes",
                "score": 0.82,
                "category": "fashion",
                "momentum": "declining",
                "peak_estimate": "6-12 months"
            }
        ]
    }

@router.get("/predict")
async def predict_trends(category: str = "fashion", user = Depends(get_current_user)):
    return {
        "predictions": [
            {
                "trend": f"Emerging {category} trend",
                "probability": round(random.uniform(0.6, 0.95), 2),
                "timeline": "6-18 months",
                "confidence": round(random.uniform(0.7, 0.9), 2)
            }
        ]
    }
