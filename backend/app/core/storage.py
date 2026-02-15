"""MinIO storage configuration and utilities."""

from io import BytesIO
from typing import BinaryIO

from minio import Minio
from minio.error import S3Error
from PIL import Image

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

# Global MinIO client
minio_client: Minio | None = None


def get_minio_client() -> Minio:
    """Get or create MinIO client."""
    global minio_client
    if minio_client is None:
        minio_client = Minio(
            settings.MINIO_ENDPOINT,
            access_key=settings.MINIO_ACCESS_KEY,
            secret_key=settings.MINIO_SECRET_KEY,
            secure=settings.MINIO_USE_SSL,
        )
        # Ensure bucket exists
        _ensure_bucket_exists()
    return minio_client


def _ensure_bucket_exists() -> None:
    """Ensure the bucket exists, create if not."""
    try:
        client = get_minio_client()
        if not client.bucket_exists(settings.MINIO_BUCKET_NAME):
            client.make_bucket(settings.MINIO_BUCKET_NAME)
            logger.info("Bucket created", bucket=settings.MINIO_BUCKET_NAME)
    except S3Error as e:
        logger.error("Failed to ensure bucket exists", error=str(e))
        raise


async def upload_image(
    file_data: bytes,
    object_name: str,
    content_type: str = "image/jpeg",
) -> str:
    """Upload an image to MinIO."""
    try:
        client = get_minio_client()
        
        # Optimize image if needed
        image = Image.open(BytesIO(file_data))
        if image.format not in ("JPEG", "PNG", "WEBP"):
            # Convert to JPEG
            output = BytesIO()
            if image.mode in ("RGBA", "LA", "P"):
                image = image.convert("RGB")
            image.save(output, format="JPEG", quality=85, optimize=True)
            file_data = output.getvalue()
            content_type = "image/jpeg"
        
        # Upload to MinIO
        client.put_object(
            bucket_name=settings.MINIO_BUCKET_NAME,
            object_name=object_name,
            data=BytesIO(file_data),
            length=len(file_data),
            content_type=content_type,
        )
        
        # Return public URL (adjust based on your MinIO setup)
        url = f"http://{settings.MINIO_ENDPOINT}/{settings.MINIO_BUCKET_NAME}/{object_name}"
        logger.info("Image uploaded", object_name=object_name, url=url)
        return url
    except S3Error as e:
        logger.error("Failed to upload image", error=str(e), object_name=object_name)
        raise


async def delete_image(object_name: str) -> None:
    """Delete an image from MinIO."""
    try:
        client = get_minio_client()
        client.remove_object(settings.MINIO_BUCKET_NAME, object_name)
        logger.info("Image deleted", object_name=object_name)
    except S3Error as e:
        logger.error("Failed to delete image", error=str(e), object_name=object_name)
        raise


async def download_image(object_name: str) -> bytes:
    """Download an image from MinIO."""
    try:
        client = get_minio_client()
        response = client.get_object(settings.MINIO_BUCKET_NAME, object_name)
        data = response.read()
        response.close()
        response.release_conn()
        return data
    except S3Error as e:
        logger.error("Failed to download image", error=str(e), object_name=object_name)
        raise

