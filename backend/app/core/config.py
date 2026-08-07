from typing import List, Union
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import AnyHttpUrl

class Settings(BaseSettings):
    PROJECT_NAME: str = "DoseBuddy AI Backend"
    API_V1_STR: str = "/api/v1"
    PORT: int = 8000
    HOST: str = "0.0.0.0"
    
    SECRET_KEY: str = "dosebuddy-secret-key-change-in-production"
    CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8080", "*"]

    GEMINI_API_KEY: str = ""
    FIREBASE_CREDENTIALS_PATH: str = "firebase-service-account.json"
    USE_MOCK_SERVICES: bool = True
    MISSED_DOSE_THRESHOLD_MINUTES: int = 30

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True)

settings = Settings()
