#!/usr/bin/env python3
"""Script to download product images and upload them to MinIO."""

import asyncio
import sys
from pathlib import Path
from io import BytesIO
from typing import Optional

import httpx
from PIL import Image

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import select
from app.core.database import Base
from app.core.config import settings
from app.modules.products.models import Product
from app.core.storage import upload_image
from app.core.logging import configure_logging

# Configure logging
configure_logging()

# Mapping des produits avec leurs images Unsplash (meilleures images)
PRODUCT_IMAGES = {
    "prod-001": "https://images.unsplash.com/photo-1592841200221-a6898a05f2a3?w=800&q=80",  # Tomates
    "prod-002": "https://images.unsplash.com/photo-1518977822534-7049a61ee0c2?w=800&q=80",  # Oignons
    "prod-003": "https://images.unsplash.com/photo-1518977822534-7049a61ee0c2?w=800&q=80",  # Pommes de terre
    "prod-004": "https://images.unsplash.com/photo-1605027990121-4a0e4c8c5e5a?w=800&q=80",  # Mangues
    "prod-005": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800&q=80",  # Bananes plantain
    "prod-006": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&q=80",  # Riz
    "prod-007": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&q=80",  # Huile de palme
    "prod-008": "https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=800&q=80",  # Poulet
    "prod-009": "https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=800&q=80",  # Poisson
    "prod-010": "https://images.unsplash.com/photo-1592841200221-a6898a05f2a3?w=800&q=80",  # Gombo
    "prod-011": "https://images.unsplash.com/photo-1592841200221-a6898a05f2a3?w=800&q=80",  # Aubergines
    "prod-012": "https://images.unsplash.com/photo-1605027990121-4a0e4c8c5e5a?w=800&q=80",  # Ananas
    "prod-013": "https://images.unsplash.com/photo-1592841200221-a6898a05f2a3?w=800&q=80",  # Piments
    "prod-014": "https://images.unsplash.com/photo-1592841200221-a6898a05f2a3?w=800&q=80",  # Ail
    "prod-015": "https://images.unsplash.com/photo-1592841200221-a6898a05f2a3?w=800&q=80",  # Gingembre
}


async def download_image(url: str) -> Optional[bytes]:
    """Download an image from URL."""
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(url, follow_redirects=True)
            response.raise_for_status()
            return response.content
    except Exception as e:
        print(f"❌ Erreur lors du téléchargement de {url}: {e}")
        return None


async def process_product_images():
    """Download and upload images for all products."""
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
            print("⚠️  Aucun produit trouvé. Exécutez d'abord 'make seed'")
            return
        
        print(f"📦 {len(products)} produits trouvés\n")
        
        uploaded_count = 0
        skipped_count = 0
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            for product in products:
                # Check if product already has a MinIO URL
                if product.image_url and "minio" in product.image_url.lower():
                    print(f"⏭️  {product.name}: Image déjà uploadée")
                    skipped_count += 1
                    continue
                
                # Get image URL from mapping or use existing
                image_url = PRODUCT_IMAGES.get(product.id, product.image_url)
                
                if not image_url:
                    print(f"⚠️  {product.name}: Pas d'URL d'image disponible")
                    skipped_count += 1
                    continue
                
                print(f"⬇️  Téléchargement: {product.name}...")
                
                # Download image
                image_data = await download_image(image_url)
                if not image_data:
                    skipped_count += 1
                    continue
                
                # Upload to MinIO
                try:
                    object_name = f"products/{product.id}.jpg"
                    minio_url = await upload_image(
                        file_data=image_data,
                        object_name=object_name,
                        content_type="image/jpeg",
                    )
                    
                    # Update product with MinIO URL
                    product.image_url = minio_url
                    await session.commit()
                    
                    print(f"✅ {product.name}: Image uploadée → {minio_url}")
                    uploaded_count += 1
                    
                except Exception as e:
                    print(f"❌ {product.name}: Erreur lors de l'upload → {e}")
                    skipped_count += 1
                    await session.rollback()
        
        print(f"\n📊 Résumé:")
        print(f"   ✅ {uploaded_count} images uploadées")
        print(f"   ⏭️  {skipped_count} images ignorées")
    
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(process_product_images())

