"""Logistics schemas."""

from typing import Optional

from pydantic import ConfigDict, Field

from app.core.schemas import BaseSchema, TimestampSchema


class BoxBase(BaseSchema):
    """Base box fields."""

    name: str = Field(..., min_length=2, max_length=140)
    city: str = Field(..., min_length=2, max_length=120)
    zone: str = Field(..., min_length=2, max_length=120)
    address: Optional[str] = Field(None, max_length=300)
    latitude: Optional[str] = None
    longitude: Optional[str] = None
    owner_user_id: Optional[str] = None
    status: str = Field(default="active", min_length=3, max_length=50)
    total_lockers: int = Field(default=0, ge=0)
    available_lockers: int = Field(default=0, ge=0)
    supports_transit: bool = True


class BoxCreate(BoxBase):
    """Create a box."""


class BoxResponse(BoxBase, TimestampSchema):
    """Box response."""

    id: str

    model_config = ConfigDict(from_attributes=True)


class ParcelCreate(BaseSchema):
    """Create a parcel."""

    order_id: str
    listing_id: str
    seller_id: str
    buyer_id: str
    origin_box_id: Optional[str] = None
    destination_box_id: Optional[str] = None
    current_box_id: Optional[str] = None
    parcel_size: str = Field(default="M", min_length=1, max_length=10)
    delivery_mode: str = Field(default="same_zone", min_length=3, max_length=50)


class ParcelResponse(TimestampSchema):
    """Parcel response."""

    id: str
    order_id: str
    listing_id: str
    seller_id: str
    buyer_id: str
    origin_box_id: Optional[str] = None
    destination_box_id: Optional[str] = None
    current_box_id: Optional[str] = None
    parcel_size: str
    delivery_mode: str
    status: str
    locker_state: str

    model_config = ConfigDict(from_attributes=True)


class ShipmentCreate(BaseSchema):
    """Create a shipment."""

    parcel_id: str
    origin_box_id: Optional[str] = None
    destination_box_id: Optional[str] = None
    route_code: Optional[str] = None
    vehicle_code: Optional[str] = None
    distance_km: Optional[float] = Field(None, ge=0)


class ShipmentResponse(TimestampSchema):
    """Shipment response."""

    id: str
    parcel_id: str
    origin_box_id: Optional[str] = None
    destination_box_id: Optional[str] = None
    route_code: Optional[str] = None
    vehicle_code: Optional[str] = None
    status: str
    distance_km: Optional[float] = None

    model_config = ConfigDict(from_attributes=True)
