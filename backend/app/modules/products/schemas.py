"""Product Pydantic schemas."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field, ConfigDict

from app.core.schemas import BaseSchema, TimestampSchema


class ProductBase(BaseSchema):
    """Base product schema."""

    name: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    price: float = Field(..., gt=0, description="Prix en FCFA")
    original_price: Optional[float] = Field(None, gt=0)
    image_url: Optional[str] = None
    category: str = Field(..., min_length=1, max_length=100)
    unit: Optional[str] = Field(None, max_length=20)  # kg, L, pièce, etc.
    is_available: bool = True


class ProductCreate(ProductBase):
    """Schema for creating a product."""

    price_min: Optional[float] = Field(None, gt=0, description="P_min pour négociation")
    price_target: Optional[float] = Field(None, gt=0, description="P_target pour négociation")
    price_max: Optional[float] = Field(None, gt=0, description="P_max pour négociation")


class ProductUpdate(BaseSchema):
    """Schema for updating a product."""

    name: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=1000)
    price: Optional[float] = Field(None, gt=0)
    original_price: Optional[float] = Field(None, gt=0)
    image_url: Optional[str] = None
    category: Optional[str] = Field(None, min_length=1, max_length=100)
    unit: Optional[str] = Field(None, max_length=20)
    is_available: Optional[bool] = None
    price_min: Optional[float] = Field(None, gt=0)
    price_target: Optional[float] = Field(None, gt=0)
    price_max: Optional[float] = Field(None, gt=0)


class ProductResponse(ProductBase, TimestampSchema):
    """Schema for product response."""

    id: str
    price_min: Optional[float] = None
    price_target: Optional[float] = None
    price_max: Optional[float] = None

    model_config = ConfigDict(from_attributes=True)


class ProductListResponse(BaseSchema):
    """Schema for product list response."""

    items: list[ProductResponse]
    total: int
    page: int
    page_size: int
    pages: int

