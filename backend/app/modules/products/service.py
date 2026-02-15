"""Product service layer."""

from typing import Optional
from uuid import uuid4

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundError
from app.modules.products.models import Product
from app.modules.products.schemas import ProductCreate, ProductUpdate
from app.core.schemas import PaginationParams


class ProductService:
    """Service for product operations."""

    @staticmethod
    async def get_by_id(db: AsyncSession, product_id: str) -> Product:
        """Get a product by ID."""
        result = await db.execute(
            select(Product).where(Product.id == product_id)
        )
        product = result.scalar_one_or_none()
        if not product:
            raise NotFoundError("Product")
        return product

    @staticmethod
    async def get_all(
        db: AsyncSession,
        pagination: PaginationParams,
        category: Optional[str] = None,
        search: Optional[str] = None,
        is_available: Optional[bool] = None,
    ) -> tuple[list[Product], int]:
        """Get all products with filters."""
        query = select(Product)

        # Apply filters
        if category:
            query = query.where(Product.category == category)
        if search:
            search_term = f"%{search.lower()}%"
            query = query.where(
                (Product.name.ilike(search_term))
                | (Product.description.ilike(search_term))
            )
        if is_available is not None:
            query = query.where(Product.is_available == is_available)

        # Get total count
        count_query = select(func.count()).select_from(query.subquery())
        total_result = await db.execute(count_query)
        total = total_result.scalar_one()

        # Apply pagination
        query = query.offset(pagination.skip).limit(pagination.limit)
        query = query.order_by(Product.created_at.desc())

        result = await db.execute(query)
        products = result.scalars().all()

        return list(products), total

    @staticmethod
    async def create(db: AsyncSession, product_data: ProductCreate) -> Product:
        """Create a new product."""
        product = Product(
            id=str(uuid4()),
            **product_data.model_dump(),
        )
        db.add(product)
        await db.commit()
        await db.refresh(product)
        return product

    @staticmethod
    async def update(
        db: AsyncSession, product_id: str, product_data: ProductUpdate
    ) -> Product:
        """Update a product."""
        product = await ProductService.get_by_id(db, product_id)

        update_data = product_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(product, field, value)

        await db.commit()
        await db.refresh(product)
        return product

    @staticmethod
    async def delete(db: AsyncSession, product_id: str) -> None:
        """Delete a product."""
        product = await ProductService.get_by_id(db, product_id)
        await db.delete(product)
        await db.commit()

    @staticmethod
    async def get_categories(db: AsyncSession) -> list[str]:
        """Get all unique categories."""
        query = select(Product.category).distinct()
        result = await db.execute(query)
        categories = result.scalars().all()
        return list(categories)

