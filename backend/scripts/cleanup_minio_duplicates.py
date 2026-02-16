#!/usr/bin/env python3
"""Script to clean up duplicate objects in MinIO bucket."""

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


def cleanup_duplicates():
    """Remove duplicate objects with 'products/' prefix."""
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
        
        print(f"Cleaning up duplicates in bucket '{settings.MINIO_BUCKET_NAME}':\n")
        
        objects = client.list_objects(settings.MINIO_BUCKET_NAME, recursive=True)
        deleted_count = 0
        
        for obj in objects:
            # Remove objects with 'products/' prefix (duplicates)
            if obj.object_name.startswith("products/"):
                try:
                    client.remove_object(settings.MINIO_BUCKET_NAME, obj.object_name)
                    print(f"DELETED: {obj.object_name}")
                    deleted_count += 1
                except S3Error as e:
                    print(f"ERREUR: Failed to delete {obj.object_name}: {e}")
        
        if deleted_count == 0:
            print("No duplicates found")
        else:
            print(f"\nTotal: {deleted_count} duplicate objects removed")
        
    except Exception as e:
        print(f"ERREUR: {e}")


if __name__ == "__main__":
    cleanup_duplicates()

