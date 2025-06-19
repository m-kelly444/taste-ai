from fastapi import APIRouter, File, UploadFile, HTTPException
from PIL import Image
import io
import numpy as np
import random

router = APIRouter()

# Simple aesthetic model
class SimpleAestheticModel:
    def predict(self, image):
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        img_array = np.array(image)
        colors = img_array.reshape(-1, 3)
        color_variance = np.var(colors, axis=0).mean()
        brightness = np.mean(colors) / 255.0
        
        base_score = 0.6
        if 0.3 <= brightness <= 0.7:
            base_score += 0.1
        if 50 <= color_variance <= 150:
            base_score += 0.1
        base_score += random.uniform(-0.1, 0.2)
        
        return max(0.1, min(0.95, base_score))

aesthetic_model = SimpleAestheticModel()

class SimpleTasteScorer:
    def analyze_trends(self, image):
        return {
            "trend_score": round(random.uniform(0.6, 0.9), 2),
            "viral_potential": round(random.uniform(0.5, 0.8), 2),
            "market_appeal": round(random.uniform(0.7, 0.95), 2),
            "seasonal_relevance": round(random.uniform(0.6, 0.85), 2)
        }

taste_scorer = SimpleTasteScorer()

@router.post("/score-public")
async def score_aesthetic_public(file: UploadFile = File(...)):
    """Public aesthetic scoring endpoint for testing"""
    try:
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="File must be an image")
        
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        
        score = aesthetic_model.predict(image)
        trends = taste_scorer.analyze_trends(image)
        
        return {
            "aesthetic_score": float(score),
            "trend_analysis": trends,
            "confidence": float(score * 0.95),
            "metadata": {
                "image_size": image.size,
                "format": image.format,
                "model_version": "public_test_v1.0"
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")
