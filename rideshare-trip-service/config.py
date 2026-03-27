import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Database
    DATABASE_URL = os.getenv("DATABASE_URL")
    
    # Redis — prefer REDIS_HOST/PORT (no auth) over REDIS_URL (may contain stale password)
    _redis_host = os.getenv("REDIS_HOST")
    _redis_port = os.getenv("REDIS_PORT", "6379")
    if _redis_host:
        REDIS_URL = f"redis://{_redis_host}:{_redis_port}"
    else:
        REDIS_URL = os.getenv("REDIS_URL")
    
    # Service
    PORT = int(os.getenv("PORT", 8000))
    DEBUG = os.getenv("DEBUG", "False").lower() == "true"
    
    # CORS
    ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")