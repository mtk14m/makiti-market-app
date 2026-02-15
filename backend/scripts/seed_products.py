#!/usr/bin/env python3
"""Seed script to populate products database with West African market products."""

import asyncio
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.core.database import Base
from app.core.config import settings
from app.modules.products.models import Product
from app.core.logging import configure_logging

# Configure logging
configure_logging()

# Products data - Produits du marché ouest-africain
PRODUCTS_DATA = [
    {
        "id": "prod-001",
        "name": "Tomates fraîches",
        "description": "Tomates rouges et juteuses du marché local",
        "price": 1500.0,  # FCFA/kg
        "category": "Légumes",
        "unit": "kg",
        "is_available": True,
        "price_min": 1200.0,
        "price_target": 1500.0,
        "price_max": 1800.0,
        "image_url": "https://images.unsplash.com/photo-1546094097-3c4b0b0e0b0b?w=400",
    },
    {
        "id": "prod-002",
        "name": "Oignons",
        "description": "Oignons locaux de qualité",
        "price": 1200.0,
        "category": "Légumes",
        "unit": "kg",
        "is_available": True,
        "price_min": 1000.0,
        "price_target": 1200.0,
        "price_max": 1500.0,
        "image_url": "https://images.unsplash.com/photo-1518977822534-7049a61ee0c2?w=400",
    },
    {
        "id": "prod-003",
        "name": "Pommes de terre",
        "description": "Pommes de terre fraîches",
        "price": 1800.0,
        "original_price": 2000.0,
        "category": "Légumes",
        "unit": "kg",
        "is_available": True,
        "price_min": 1500.0,
        "price_target": 1800.0,
        "price_max": 2200.0,
        "image_url": "https://images.unsplash.com/photo-1518977822534-7049a61ee0c2?w=400",
    },
    {
        "id": "prod-004",
        "name": "Mangues",
        "description": "Mangues sucrées de saison",
        "price": 2500.0,
        "category": "Fruits",
        "unit": "kg",
        "is_available": True,
        "price_min": 2000.0,
        "price_target": 2500.0,
        "price_max": 3000.0,
        "image_url": "https://images.unsplash.com/photo-1605027990121-4a0e4c8c5e5a?w=400",
    },
    {
        "id": "prod-005",
        "name": "Bananes plantain",
        "description": "Bananes plantain mûres",
        "price": 1000.0,
        "category": "Fruits",
        "unit": "kg",
        "is_available": True,
        "price_min": 800.0,
        "price_target": 1000.0,
        "price_max": 1200.0,
        "image_url": "https://images.unsplash.com/photo-1605027990121-4a0e4c8c5e5a?w=400",
    },
    {
        "id": "prod-006",
        "name": "Riz local",
        "description": "Riz de qualité supérieure",
        "price": 3500.0,
        "category": "Épicerie",
        "unit": "kg",
        "is_available": True,
        "price_min": 3000.0,
        "price_target": 3500.0,
        "price_max": 4000.0,
        "image_url": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400",
    },
    {
        "id": "prod-007",
        "name": "Huile de palme",
        "description": "Huile de palme naturelle",
        "price": 2800.0,
        "category": "Épicerie",
        "unit": "L",
        "is_available": True,
        "price_min": 2500.0,
        "price_target": 2800.0,
        "price_max": 3200.0,
        "image_url": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400",
    },
    {
        "id": "prod-008",
        "name": "Poulet frais",
        "description": "Poulet fermier",
        "price": 4500.0,
        "category": "Viande",
        "unit": "kg",
        "is_available": True,
        "price_min": 4000.0,
        "price_target": 4500.0,
        "price_max": 5000.0,
        "image_url": "https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400",
    },
    {
        "id": "prod-009",
        "name": "Poisson frais",
        "description": "Poisson du jour",
        "price": 5000.0,
        "category": "Poisson",
        "unit": "kg",
        "is_available": True,
        "price_min": 4500.0,
        "price_target": 5000.0,
        "price_max": 6000.0,
        "image_url": "https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400",
    },
    {
        "id": "prod-010",
        "name": "Gombo",
        "description": "Gombo frais",
        "price": 2000.0,
        "category": "Légumes",
        "unit": "kg",
        "is_available": True,
        "price_min": 1500.0,
        "price_target": 2000.0,
        "price_max": 2500.0,
        "image_url": "https://images.unsplash.com/photo-1546094097-3c4b0b0e0b0b?w=400",
    },
    {
        "id": "prod-011",
        "name": "Aubergines",
        "description": "Aubergines locales",
        "price": 1800.0,
        "category": "Légumes",
        "unit": "kg",
        "is_available": True,
        "price_min": 1500.0,
        "price_target": 1800.0,
        "price_max": 2200.0,
        "image_url": "https://images.unsplash.com/photo-1546094097-3c4b0b0e0b0b?w=400",
    },
    {
        "id": "prod-012",
        "name": "Ananas",
        "description": "Ananas sucrés et juteux",
        "price": 2000.0,
        "category": "Fruits",
        "unit": "pièce",
        "is_available": True,
        "price_min": 1500.0,
        "price_target": 2000.0,
        "price_max": 2500.0,
        "image_url": "https://images.unsplash.com/photo-1605027990121-4a0e4c8c5e5a?w=400",
    },
    {
        "id": "prod-013",
        "name": "Piments",
        "description": "Piments rouges frais",
        "price": 1500.0,
        "category": "Légumes",
        "unit": "kg",
        "is_available": True,
        "price_min": 1200.0,
        "price_target": 1500.0,
        "price_max": 1800.0,
        "image_url": "https://images.unsplash.com/photo-1546094097-3c4b0b0e0b0b?w=400",
    },
    {
        "id": "prod-014",
        "name": "Ail",
        "description": "Ail frais",
        "price": 3000.0,
        "category": "Légumes",
        "unit": "kg",
        "is_available": True,
        "price_min": 2500.0,
        "price_target": 3000.0,
        "price_max": 3500.0,
        "image_url": "https://images.unsplash.com/photo-1546094097-3c4b0b0e0b0b?w=400",
    },
    {
        "id": "prod-015",
        "name": "Gingembre",
        "description": "Gingembre frais",
        "price": 4000.0,
        "category": "Légumes",
        "unit": "kg",
        "is_available": True,
        "price_min": 3500.0,
        "price_target": 4000.0,
        "price_max": 4500.0,
        "image_url": "https://images.unsplash.com/photo-1546094097-3c4b0b0e0b0b?w=400",
    },
]


async def seed_products():
    """Seed products into the database."""
    # Create async engine
    async_database_url = settings.DATABASE_URL.replace(
        "postgresql://", "postgresql+asyncpg://"
    )
    engine = create_async_engine(async_database_url, echo=False)
    
    # Create tables if they don't exist
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Create session
    async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    async with async_session() as session:
        # Check if products already exist
        from sqlalchemy import select, func
        result = await session.execute(select(func.count(Product.id)))
        count = result.scalar_one()
        
        if count > 0:
            print(f"⚠️  {count} products already exist. Skipping seed.")
            return
        
        # Create products
        products = []
        for product_data in PRODUCTS_DATA:
            product = Product(**product_data)
            products.append(product)
            session.add(product)
        
        await session.commit()
        print(f"✅ Successfully seeded {len(products)} products!")
        
        # Print summary
        categories = {}
        for product in products:
            categories[product.category] = categories.get(product.category, 0) + 1
        
        print("\n📊 Summary by category:")
        for category, count in sorted(categories.items()):
            print(f"   - {category}: {count} products")


if __name__ == "__main__":
    asyncio.run(seed_products())

