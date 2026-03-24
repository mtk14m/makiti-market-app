"""Commerce schemas."""

from typing import Optional

from pydantic import ConfigDict, Field

from app.core.schemas import BaseSchema, TimestampSchema


class ListingBase(BaseSchema):
    """Common listing fields."""

    title: str = Field(..., min_length=3, max_length=140)
    description: Optional[str] = Field(None, max_length=4000)
    price: float = Field(..., gt=0)
    currency: str = Field(default="XOF", min_length=3, max_length=3)
    category: str = Field(..., min_length=2, max_length=120)
    brand: Optional[str] = Field(None, max_length=120)
    size: Optional[str] = Field(None, max_length=50)
    condition: str = Field(default="good", min_length=2, max_length=50)
    cover_image_url: Optional[str] = None
    photo_urls: list[str] = Field(default_factory=list)
    location_label: Optional[str] = Field(None, max_length=200)
    seller_box_id: Optional[str] = None
    parcel_size: str = Field(default="M", min_length=1, max_length=10)
    is_negotiable: bool = True


class ListingCreate(ListingBase):
    """Payload to create a listing."""


class ListingUpdate(BaseSchema):
    """Payload to update a listing."""

    title: Optional[str] = Field(None, min_length=3, max_length=140)
    description: Optional[str] = Field(None, max_length=4000)
    price: Optional[float] = Field(None, gt=0)
    category: Optional[str] = Field(None, min_length=2, max_length=120)
    brand: Optional[str] = Field(None, max_length=120)
    size: Optional[str] = Field(None, max_length=50)
    condition: Optional[str] = Field(None, min_length=2, max_length=50)
    cover_image_url: Optional[str] = None
    photo_urls: Optional[list[str]] = None
    location_label: Optional[str] = Field(None, max_length=200)
    seller_box_id: Optional[str] = None
    parcel_size: Optional[str] = Field(None, min_length=1, max_length=10)
    is_negotiable: Optional[bool] = None
    status: Optional[str] = Field(None, min_length=3, max_length=50)


class ListingResponse(ListingBase, TimestampSchema):
    """Listing response."""

    id: str
    seller_id: str
    status: str

    model_config = ConfigDict(from_attributes=True)


class ListingListResponse(BaseSchema):
    """Paginated listings."""

    items: list[ListingResponse]
    total: int
    page: int
    page_size: int
    pages: int


class OrderCreate(BaseSchema):
    """Payload to create a marketplace order."""

    listing_id: str
    buyer_box_id: Optional[str] = None
    seller_box_id: Optional[str] = None


class OrderResponse(TimestampSchema):
    """Marketplace order response."""

    id: str
    listing_id: str
    buyer_id: str
    seller_id: str
    buyer_box_id: Optional[str] = None
    seller_box_id: Optional[str] = None
    status: str
    item_price: float
    buyer_fee: float
    logistics_fee: float
    platform_fee: float
    total_amount: float
    currency: str
    payment_status: str
    escrow_status: str

    model_config = ConfigDict(from_attributes=True)


class ListingImageUploadResponse(BaseSchema):
    """Response returned after uploading a listing image."""

    url: str
    object_name: str
