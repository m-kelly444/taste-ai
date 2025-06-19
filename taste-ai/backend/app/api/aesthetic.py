from fastapi import APIRouter, File, UploadFile, HTTPException, Depends
from fastapi.responses import JSONResponse
from PIL import Image
import io
import numpy as np
from app.ml.inference import AestheticModel
from app.services.taste_scorer import TasteScorer
from app.core.security import get_current_user

router = APIRouter()
aesthetic_model = AestheticModel()
taste_scorer = TasteScorer()

@router.post("/score")
async def score_aesthetic(
    file: UploadFile = File(...),
    user = Depends(get_current_user)
):
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
                "format": image.format
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/batch-score")
async def batch_score_aesthetic(
    files: list[UploadFile] = File(...),
    user = Depends(get_current_user)
):
    results = []
    
    for file in files:
        try:
            image_data = await file.read()
            image = Image.open(io.BytesIO(image_data))
            score = aesthetic_model.predict(image)
            
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
