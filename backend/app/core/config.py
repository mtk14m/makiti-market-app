"""Application configuration using Pydantic Settings."""

from typing import List, Any

from pydantic import Field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Project
    PROJECT_NAME: str = "Makiti Market API"
    ENVIRONMENT: str = Field(default="development")
    DEBUG: bool = Field(default=False)

    # API
    API_V1_STR: str = "/api/v1"
    API_PORT: int = Field(default=8000)

    # Database
    DATABASE_URL: str = Field(
        default="postgresql://makiti:makiti_password@localhost:5432/makiti_db"
    )
    POSTGRES_USER: str = Field(default="makiti")
    POSTGRES_PASSWORD: str = Field(default="makiti_password")
    POSTGRES_DB: str = Field(default="makiti_db")
    POSTGRES_PORT: int = Field(default=5432)

    # Redis
    REDIS_URL: str = Field(default="redis://localhost:6379/0")
    REDIS_PORT: int = Field(default=6379)

    # Security
    SECRET_KEY: str = Field(
        default="change-me-in-production-use-secret-key-generator"
    )
    ALGORITHM: str = Field(default="HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=30)
    REFRESH_TOKEN_EXPIRE_DAYS: int = Field(default=7)

    # CORS - stored as string, converted to list
    CORS_ORIGINS: str = Field(
        default="http://localhost:3000,http://localhost:8080"
    )

    @property
    def cors_origins_list(self) -> List[str]:
        """Get CORS origins as a list."""
        if isinstance(self.CORS_ORIGINS, list):
            return self.CORS_ORIGINS
        return [
            origin.strip()
            for origin in self.CORS_ORIGINS.split(",")
            if origin.strip()
        ]

    # Sentry
    SENTRY_DSN: str | None = Field(default=None)

    # Logging
    LOG_LEVEL: str = Field(default="INFO")

    # BullMQ
    BULLMQ_REDIS_URL: str | None = None  # Uses REDIS_URL if not set

    # MinIO (S3-compatible storage)
    MINIO_ENDPOINT: str = Field(default="localhost:9000")
    MINIO_PUBLIC_ENDPOINT: str = Field(
        default="localhost:9000",
        description="Public endpoint for mobile app (usually localhost:9000 in dev)"
    )
    MINIO_ACCESS_KEY: str = Field(default="minioadmin")
    MINIO_SECRET_KEY: str = Field(default="minioadmin123")
    MINIO_BUCKET_NAME: str = Field(default="products")
    MINIO_USE_SSL: bool = Field(default=False)


settings = Settings()


