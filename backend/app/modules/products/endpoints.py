"""Product API endpoints."""

from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import DatabaseDep
from app.core.schemas import PaginationParams
from app.modules.products import schemas, service

router = APIRouter()


@router.get("", response_model=schemas.ProductListResponse)
async def get_products(
    pagination: PaginationParams = Depends(),
    category: Optional[str] = Query(None, description="Filtrer par catégorie"),
    search: Optional[str] = Query(None, description="Rechercher dans les produits"),
    is_available: Optional[bool] = Query(None, description="Filtrer par disponibilité"),
    db: DatabaseDep = None,
) -> schemas.ProductListResponse:
    """Get all products with pagination and filters."""
    products, total = await service.ProductService.get_all(
        db=db,
        pagination=pagination,
        category=category,
        search=search,
        is_available=is_available,
    )

    total_pages = (total + pagination.page_size - 1) // pagination.page_size

    return schemas.ProductListResponse(
        items=[schemas.ProductResponse.model_validate(p) for p in products],
        total=total,
        page=pagination.page,
        page_size=pagination.page_size,
        pages=total_pages,
    )


@router.get("/{product_id}", response_model=schemas.ProductResponse)
async def get_product(
    product_id: str,
    db: DatabaseDep = None,
) -> schemas.ProductResponse:
    """Get a product by ID."""
    product = await service.ProductService.get_by_id(db, product_id)
    return schemas.ProductResponse.model_validate(product)


@router.post("", response_model=schemas.ProductResponse, status_code=201)
async def create_product(
    product_data: schemas.ProductCreate,
    db: DatabaseDep = None,
) -> schemas.ProductResponse:
    """Create a new product."""
    product = await service.ProductService.create(db, product_data)
    return schemas.ProductResponse.model_validate(product)


@router.put("/{product_id}", response_model=schemas.ProductResponse)
async def update_product(
    product_id: str,
    product_data: schemas.ProductUpdate,
    db: DatabaseDep = None,
) -> schemas.ProductResponse:
    """Update a product."""
    product = await service.ProductService.update(db, product_id, product_data)
    return schemas.ProductResponse.model_validate(product)


@router.delete("/{product_id}", status_code=204)
async def delete_product(
    product_id: str,
    db: DatabaseDep = None,
) -> None:
    """Delete a product."""
    await service.ProductService.delete(db, product_id)


@router.get("/categories/list", response_model=list[str])
async def get_categories(
    db: DatabaseDep = None,
) -> list[str]:
    """Get all product categories."""
    categories = await service.ProductService.get_categories(db)
    return categories

