"""Initialize storage (MinIO) on startup."""

from app.core.storage import get_minio_client, _ensure_bucket_exists
from app.core.logging import get_logger

logger = get_logger(__name__)


async def init_storage() -> None:
    """Initialize MinIO storage."""
    try:
        _ensure_bucket_exists()
        logger.info("Storage (MinIO) initialized")
    except Exception as e:
        logger.error("Failed to initialize storage", error=str(e))
        raise

