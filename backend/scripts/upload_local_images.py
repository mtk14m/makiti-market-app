#!/usr/bin/env python3
"""Script to upload product images from shared/assets/images to MinIO."""

import asyncio
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import select
from minio.error import S3Error
from app.core.database import Base
from app.core.config import settings
from app.modules.products.models import Product
from app.core.storage import upload_image, get_minio_client
from app.core.logging import configure_logging

# Configure logging
configure_logging()

# Path to images directory (relative to project root)
IMAGES_DIR = Path(__file__).parent.parent.parent / "shared" / "assets" / "images"


async def upload_local_images():
    """Upload product images from local directory to MinIO."""
    # Check if images directory exists
    if not IMAGES_DIR.exists():
        print(f"ERREUR: Le dossier '{IMAGES_DIR}' n'existe pas")
        print(f"Créez le dossier et placez-y les images avec les noms prod-001.jpg, prod-002.jpg, etc.")
        return
    
    # Create async engine
    async_database_url = settings.DATABASE_URL.replace(
        "postgresql://", "postgresql+asyncpg://"
    )
    engine = create_async_engine(async_database_url, echo=False)
    
    # Create session
    async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    async with async_session() as session:
        # Get all products
        result = await session.execute(select(Product))
        products = result.scalars().all()
        
        if not products:
            print("ATTENTION: Aucun produit trouvé. Exécutez d'abord 'make seed'")
            return
        
        print(f"{len(products)} produits trouvés\n")
        print(f"Recherche des images dans: {IMAGES_DIR}\n")
        
        uploaded_count = 0
        skipped_count = 0
        not_found_count = 0
        
        # Get MinIO client for checking objects
        minio_client = get_minio_client()
        
        for product in products:
            # Check if product already has a MinIO URL and object exists
            object_name = f"{product.id}.jpg"
            image_path = IMAGES_DIR / f"{product.id}.jpg"
            
            # Check if image file exists
            if not image_path.exists():
                print(f"SKIP: {product.name}: Image non trouvée ({image_path.name})")
                not_found_count += 1
                continue
            
            # Check if already uploaded
            if product.image_url and "minio" in product.image_url.lower():
                try:
                    minio_client.stat_object(settings.MINIO_BUCKET_NAME, object_name)
                    print(f"SKIP: {product.name}: Image déjà uploadée")
                    skipped_count += 1
                    continue
                except S3Error:
                    # Object doesn't exist, re-upload
                    print(f"RE-UPLOAD: {product.name}: URL existe mais objet manquant")
            
            print(f"Upload: {product.name}...")
            
            try:
                # Read image file
                with open(image_path, "rb") as f:
                    image_data = f.read()
                
                # Upload to MinIO
                minio_url = await upload_image(
                    file_data=image_data,
                    object_name=object_name,
                    content_type="image/jpeg",
                )
                
                # Update product with MinIO URL
                product.image_url = minio_url
                await session.commit()
                
                print(f"OK: {product.name}: Image uploadée → {minio_url}")
                uploaded_count += 1
                
            except Exception as e:
                print(f"ERREUR: {product.name}: Erreur lors de l'upload → {e}")
                skipped_count += 1
                await session.rollback()
        
        print(f"\nRésumé:")
        print(f"   - {uploaded_count} images uploadées")
        print(f"   - {skipped_count} images ignorées (déjà uploadées ou erreur)")
        print(f"   - {not_found_count} images non trouvées")
    
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(upload_local_images())

