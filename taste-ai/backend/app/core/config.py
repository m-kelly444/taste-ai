from pydantic_settings import BaseSettings
from typing import List, Optional

class Settings(BaseSettings):
    # Core settings
    database_url: str = "postgresql://user:password@localhost:5434/tasteai"
    redis_url: str = "redis://localhost:6381"
    secret_key: str = "dev-secret-key"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    allowed_hosts: List[str] = ["http://localhost:3000", "http://localhost:3001", "http://localhost:3002"]
    
    # Optional API keys (for future use)
    openai_api_key: Optional[str] = None
    aws_access_key_id: Optional[str] = None
    aws_secret_access_key: Optional[str] = None
    s3_bucket_name: Optional[str] = None
    
    class Config:
        env_file = ".env"
        extra = "allow"  # Allow extra fields without validation errors

settings = Settings()
