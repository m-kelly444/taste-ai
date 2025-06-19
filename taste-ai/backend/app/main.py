from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from app.api import aesthetic, trends, auth, metrics
from app.core.config import settings

app = FastAPI(
    title="TASTE.AI",
    description="Aesthetic Intelligence Platform",
    version="1.0.0",
    docs_url="/api/docs"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:3001", "http://localhost:3002"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(aesthetic.router, prefix="/api/v1/aesthetic", tags=["aesthetic"])
app.include_router(trends.router, prefix="/api/v1/trends", tags=["trends"])
app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(metrics.router, tags=["metrics"])

@app.get("/")
async def root():
    return {"message": "TASTE.AI - Aesthetic Intelligence Platform", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "version": "1.0.0"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
