#!/usr/bin/env python3
"""Script to check objects in MinIO bucket."""

import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from minio import Minio
from app.core.config import settings
from app.core.logging import configure_logging

# Configure logging
configure_logging()


def check_objects():
    """List all objects in MinIO bucket."""
    try:
        client = Minio(
            settings.MINIO_ENDPOINT,
            access_key=settings.MINIO_ACCESS_KEY,
            secret_key=settings.MINIO_SECRET_KEY,
            secure=settings.MINIO_USE_SSL,
        )
        
        if not client.bucket_exists(settings.MINIO_BUCKET_NAME):
            print(f"ERREUR: Bucket '{settings.MINIO_BUCKET_NAME}' does not exist")
            return
        
        print(f"Objects in bucket '{settings.MINIO_BUCKET_NAME}':\n")
        
        objects = client.list_objects(settings.MINIO_BUCKET_NAME, recursive=True)
        count = 0
        for obj in objects:
            print(f"  - {obj.object_name} (size: {obj.size} bytes)")
            count += 1
        
        if count == 0:
            print("  (no objects found)")
            print("\nATTENTION: No images uploaded. Run 'make download-images' first.")
        else:
            print(f"\nTotal: {count} objects")
        
    except Exception as e:
        print(f"ERREUR: {e}")


if __name__ == "__main__":
    check_objects()

