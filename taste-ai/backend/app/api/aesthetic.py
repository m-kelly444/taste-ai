from fastapi import APIRouter, File, UploadFile, HTTPException
from PIL import Image
import io
import random

router = APIRouter()

@router.post("/score")
async def score_aesthetic(file: UploadFile = File(...)):
    """Simple aesthetic scoring - no authentication for now"""
    try:
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="File must be an image")
        
        # Read and process image
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        
        # Simple scoring algorithm
        width, height = image.size
        aspect_ratio = width / height
        
        # Base score
        score = 0.6
        
        # Prefer certain aspect ratios
        if 0.8 <= aspect_ratio <= 1.25:  # Square-ish
            score += 0.1
        elif 1.4 <= aspect_ratio <= 1.7:  # Golden ratio
            score += 0.15
        
        # Add some randomness
        score += random.uniform(-0.05, 0.25)
        score = max(0.1, min(0.95, score))
        
        return {
            "aesthetic_score": float(score),
            "confidence": float(score * 0.9),
            "trend_analysis": {
                "trend_score": round(random.uniform(0.6, 0.9), 2),
                "viral_potential": round(random.uniform(0.5, 0.8), 2),
                "market_appeal": round(random.uniform(0.7, 0.95), 2),
                "seasonal_relevance": round(random.uniform(0.6, 0.85), 2)
            },
            "metadata": {
                "image_size": image.size,
                "format": image.format,
                "model_version": "simple_v1.0"
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

@router.post("/batch-score")
async def batch_score_aesthetic(files: list[UploadFile] = File(...)):
    """Batch aesthetic scoring"""
    results = []
    
    for file in files:
        try:
            image_data = await file.read()
            image = Image.open(io.BytesIO(image_data))
            
            # Simple scoring
            score = 0.6 + random.uniform(-0.1, 0.3)
            score = max(0.1, min(0.95, score))
            
            results.append({
                "filename": file.filename,
                "aesthetic_score": float(score),
                "status": "success"
            })
        except Exception as e:
            results.append({
                "filename": file.filename,
                "error": str(e),
                "status": "error"
            })
    
    return {"results": results}
