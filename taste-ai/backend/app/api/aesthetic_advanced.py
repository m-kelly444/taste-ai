from fastapi import APIRouter, File, UploadFile, HTTPException, Query
from PIL import Image
import io
from app.ml.advanced_aesthetic import advanced_engine
from typing import Optional, List

router = APIRouter()

@router.post("/score-advanced")
async def score_aesthetic_advanced(
    file: UploadFile = File(...),
    analysis_depth: str = Query("comprehensive", enum=["basic", "detailed", "comprehensive"])
):
    """Advanced aesthetic scoring with comprehensive analysis"""
    try:
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="File must be an image")
        
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        
        # Run comprehensive analysis
        result = advanced_engine.analyze_comprehensive(image)
        
        # Filter response based on analysis depth
        if analysis_depth == "basic":
            return {
                "aesthetic_score": result["aesthetic_score"],
                "confidence": result["confidence"],
                "burch_alignment": result["burch_analysis"]["burch_alignment_score"],
                "commercial_appeal": result["dimension_scores"]["commercial_appeal"]
            }
        elif analysis_depth == "detailed":
            return {
                "aesthetic_score": result["aesthetic_score"],
                "dimension_scores": result["dimension_scores"],
                "burch_analysis": result["burch_analysis"],
                "trend_analysis": result["trend_analysis"],
                "confidence": result["confidence"]
            }
        else:  # comprehensive
            return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Advanced analysis failed: {str(e)}")

@router.post("/compare-images")
async def compare_images(
    files: List[UploadFile] = File(..., description="2-5 images to compare")
):
    """Compare multiple images aesthetically"""
    
    if len(files) < 2 or len(files) > 5:
        raise HTTPException(status_code=400, detail="Please upload 2-5 images for comparison")
    
    try:
        results = []
        
        for i, file in enumerate(files):
            if not file.content_type.startswith('image/'):
                continue
                
            image_data = await file.read()
            image = Image.open(io.BytesIO(image_data))
            
            analysis = advanced_engine.analyze_comprehensive(image)
            
            results.append({
                "image_index": i,
                "filename": file.filename,
                "aesthetic_score": analysis["aesthetic_score"],
                "burch_alignment": analysis["burch_analysis"]["burch_alignment_score"],
                "commercial_appeal": analysis["dimension_scores"]["commercial_appeal"],
                "investment_recommendation": analysis["burch_analysis"]["investment_recommendation"],
                "trend_potential": analysis["trend_analysis"]["viral_potential"]
            })
        
        # Rank images
        ranked = sorted(results, key=lambda x: x["aesthetic_score"], reverse=True)
        
        # Find best for different criteria
        best_overall = max(results, key=lambda x: x["aesthetic_score"])
        best_burch = max(results, key=lambda x: x["burch_alignment"])
        best_commercial = max(results, key=lambda x: x["commercial_appeal"])
        
        return {
            "comparison_results": results,
            "ranked_by_aesthetic": ranked,
            "recommendations": {
                "best_overall": best_overall,
                "best_burch_fit": best_burch,
                "best_commercial": best_commercial
            },
            "summary": {
                "total_analyzed": len(results),
                "average_score": sum(r["aesthetic_score"] for r in results) / len(results),
                "score_range": {
                    "highest": max(r["aesthetic_score"] for r in results),
                    "lowest": min(r["aesthetic_score"] for r in results)
                }
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Comparison failed: {str(e)}")

@router.post("/trend-forecast")
async def trend_forecast(
    file: UploadFile = File(...),
    market_segment: str = Query("luxury", enum=["luxury", "contemporary", "mass_market"])
):
    """Advanced trend forecasting for fashion images"""
    try:
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="File must be an image")
        
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        
        analysis = advanced_engine.analyze_comprehensive(image)
        
        # Market-specific adjustments
        market_multipliers = {
            "luxury": {"viral": 0.8, "longevity": 1.2, "price_point": 1.5},
            "contemporary": {"viral": 1.0, "longevity": 1.0, "price_point": 1.0},
            "mass_market": {"viral": 1.3, "longevity": 0.7, "price_point": 0.6}
        }
        
        multiplier = market_multipliers[market_segment]
        trend_data = analysis["trend_analysis"]
        
        # Adjusted predictions
        adjusted_viral = min(trend_data["viral_potential"] * multiplier["viral"], 1.0)
        adjusted_longevity = min(trend_data["longevity_score"] * multiplier["longevity"], 1.0)
        
        # Generate forecast
        forecast = {
            "market_segment": market_segment,
            "trend_score": (adjusted_viral + adjusted_longevity) / 2,
            "viral_potential": adjusted_viral,
            "longevity_prediction": adjusted_longevity,
            "optimal_launch_window": _calculate_launch_window(adjusted_viral, adjusted_longevity),
            "price_point_multiplier": multiplier["price_point"],
            "seasonal_relevance": _assess_seasonal_relevance(analysis),
            "competitive_advantage": _assess_competitive_advantage(analysis),
            "risk_factors": _identify_risk_factors(analysis)
        }
        
        return {
            "forecast": forecast,
            "base_analysis": {
                "aesthetic_score": analysis["aesthetic_score"],
                "burch_alignment": analysis["burch_analysis"]["burch_alignment_score"],
                "commercial_appeal": analysis["dimension_scores"]["commercial_appeal"]
            },
            "actionable_insights": analysis["insights"]
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Trend forecast failed: {str(e)}")

def _calculate_launch_window(viral: float, longevity: float) -> str:
    """Calculate optimal launch timing"""
    if viral > 0.8:
        return "IMMEDIATE - High viral potential, launch now"
    elif viral > 0.6 and longevity > 0.7:
        return "1-2 MONTHS - Build anticipation then launch"
    elif longevity > 0.8:
        return "3-6 MONTHS - Classic appeal, flexible timing"
    else:
        return "6+ MONTHS - Needs development before launch"

def _assess_seasonal_relevance(analysis: dict) -> dict:
    """Assess seasonal market relevance"""
    color_temp = analysis["color_analysis"]["color_temperature"]
    
    return {
        "spring_summer": color_temp * 0.8 + 0.2,  # Prefer warmer tones
        "fall_winter": (1 - color_temp) * 0.8 + 0.2,  # Prefer cooler tones
        "year_round": analysis["dimension_scores"]["color_harmony"]
    }

def _assess_competitive_advantage(analysis: dict) -> str:
    """Assess competitive positioning"""
    burch_score = analysis["burch_analysis"]["burch_alignment_score"]
    
    if burch_score > 0.8:
        return "STRONG - Unique Burch aesthetic differentiation"
    elif burch_score > 0.6:
        return "MODERATE - Some differentiation possible"
    else:
        return "WEAK - Highly competitive space"

def _identify_risk_factors(analysis: dict) -> list:
    """Identify potential risk factors"""
    risks = []
    
    if analysis["confidence"] < 0.6:
        risks.append("Low confidence in analysis - may need more data")
    
    if analysis["trend_analysis"]["viral_potential"] > 0.9:
        risks.append("Very high viral potential may lead to quick saturation")
    
    if analysis["dimension_scores"]["complexity"] > 0.8:
        risks.append("High complexity may limit mass market appeal")
    
    if analysis["burch_analysis"]["investment_score"] < 0.4:
        risks.append("Low investment score suggests high commercial risk")
    
    return risks if risks else ["No significant risk factors identified"]

@router.get("/market-intelligence")
async def get_market_intelligence():
    """Get current market intelligence and trends"""
    return {
        "current_trends": {
            "color_palettes": {
                "trending_up": ["sage_green", "warm_neutrals", "navy_accents"],
                "trending_down": ["neon_colors", "all_black", "bright_pastels"],
                "stable": ["classic_navy", "camel", "cream"]
            },
            "style_directions": {
                "emerging": ["sustainable_luxury", "quiet_luxury", "americana_revival"],
                "declining": ["fast_fashion_aesthetics", "logomania", "athleisure_dominance"],
                "evergreen": ["timeless_minimalism", "sophisticated_casual"]
            }
        },
        "burch_market_position": {
            "brand_strength": 0.92,
            "market_share_trend": "growing",
            "competitive_advantage": "authentic_american_luxury",
            "growth_opportunities": ["international_expansion", "mens_accessories", "home_lifestyle"]
        },
        "investment_climate": {
            "luxury_market": "strong",
            "contemporary_market": "mixed",
            "overall_sentiment": "optimistic_with_caution",
            "key_drivers": ["post_pandemic_luxury_demand", "digital_native_consumers", "sustainability_focus"]
        }
    }
