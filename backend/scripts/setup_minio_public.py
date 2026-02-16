#!/usr/bin/env python3
"""Script to configure MinIO bucket for public read access."""

import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from minio import Minio
from minio.error import S3Error
from app.core.config import settings
from app.core.logging import configure_logging

# Configure logging
configure_logging()

# Policy JSON for public read access
PUBLIC_READ_POLICY = """{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {"AWS": ["*"]},
            "Action": ["s3:GetObject"],
            "Resource": ["arn:aws:s3:::products/*"]
        }
    ]
}"""


def setup_public_access():
    """Configure MinIO bucket for public read access."""
    try:
        client = Minio(
            settings.MINIO_ENDPOINT,
            access_key=settings.MINIO_ACCESS_KEY,
            secret_key=settings.MINIO_SECRET_KEY,
            secure=settings.MINIO_USE_SSL,
        )
        
        # Ensure bucket exists
        if not client.bucket_exists(settings.MINIO_BUCKET_NAME):
            client.make_bucket(settings.MINIO_BUCKET_NAME)
            print(f"Bucket '{settings.MINIO_BUCKET_NAME}' created")
        
        # Set bucket policy for public read access
        try:
            client.set_bucket_policy(settings.MINIO_BUCKET_NAME, PUBLIC_READ_POLICY)
            print(f"OK: Bucket '{settings.MINIO_BUCKET_NAME}' configured for public read access")
        except S3Error as e:
            print(f"ERREUR: Failed to set bucket policy: {e}")
            return False
        
        return True
        
    except S3Error as e:
        print(f"ERREUR: MinIO operation failed: {e}")
        return False
    except Exception as e:
        print(f"ERREUR: Unexpected error: {e}")
        return False


if __name__ == "__main__":
    success = setup_public_access()
    sys.exit(0 if success else 1)

