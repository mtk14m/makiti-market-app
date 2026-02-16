"""Initialize storage (MinIO) on startup."""

import json
from app.core.storage import get_minio_client, _ensure_bucket_exists
from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# Policy JSON for public read access
PUBLIC_READ_POLICY = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {"AWS": ["*"]},
            "Action": ["s3:GetObject"],
            "Resource": [f"arn:aws:s3:::{settings.MINIO_BUCKET_NAME}/*"]
        }
    ]
}


async def init_storage() -> None:
    """Initialize MinIO storage and configure public read access."""
    try:
        _ensure_bucket_exists()
        
        # Set bucket policy for public read access
        try:
            client = get_minio_client()
            policy_json = json.dumps(PUBLIC_READ_POLICY)
            client.set_bucket_policy(settings.MINIO_BUCKET_NAME, policy_json)
            logger.info("Bucket configured for public read access")
        except Exception as e:
            logger.warning("Failed to set bucket policy (may need manual setup)", error=str(e))
        
        logger.info("Storage (MinIO) initialized")
    except Exception as e:
        logger.error("Failed to initialize storage", error=str(e))
        raise

