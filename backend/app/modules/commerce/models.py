"""Commerce domain models."""

from datetime import datetime
from enum import Enum

from sqlalchemy import Boolean, Column, DateTime, Float, String, Text

from app.core.database import Base


class ListingStatus(str, Enum):
    """Listing lifecycle."""

    DRAFT = "draft"
    PUBLISHED = "published"
    RESERVED = "reserved"
    SOLD = "sold"
    ARCHIVED = "archived"


class OrderStatus(str, Enum):
    """Order lifecycle."""

    PENDING_PAYMENT = "pending_payment"
    PAID = "paid"
    PROCESSING = "processing"
    READY_FOR_PICKUP = "ready_for_pickup"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
    DISPUTED = "disputed"


class Listing(Base):
    """Seller listing published on Makiti."""

    __tablename__ = "listings"

    id = Column(String, primary_key=True, index=True)
    seller_id = Column(String, nullable=False, index=True)
    title = Column(String, nullable=False, index=True)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    currency = Column(String, nullable=False, default="XOF")
    category = Column(String, nullable=False, index=True)
    brand = Column(String, nullable=True, index=True)
    size = Column(String, nullable=True)
    condition = Column(String, nullable=False, default="good")
    cover_image_url = Column(String, nullable=True)
    photo_urls = Column(Text, nullable=True)
    location_label = Column(String, nullable=True)
    seller_box_id = Column(String, nullable=True, index=True)
    parcel_size = Column(String, nullable=False, default="M")
    is_negotiable = Column(Boolean, default=True, nullable=False)
    status = Column(String, nullable=False, default=ListingStatus.PUBLISHED.value, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class PurchaseOrder(Base):
    """Marketplace order tied to a listing."""

    __tablename__ = "commerce_orders"

    id = Column(String, primary_key=True, index=True)
    listing_id = Column(String, nullable=False, index=True)
    buyer_id = Column(String, nullable=False, index=True)
    seller_id = Column(String, nullable=False, index=True)
    buyer_box_id = Column(String, nullable=True, index=True)
    seller_box_id = Column(String, nullable=True, index=True)
    status = Column(String, nullable=False, default=OrderStatus.PENDING_PAYMENT.value, index=True)
    item_price = Column(Float, nullable=False)
    buyer_fee = Column(Float, nullable=False, default=0.0)
    logistics_fee = Column(Float, nullable=False, default=0.0)
    platform_fee = Column(Float, nullable=False, default=0.0)
    total_amount = Column(Float, nullable=False)
    currency = Column(String, nullable=False, default="XOF")
    payment_status = Column(String, nullable=False, default="pending")
    escrow_status = Column(String, nullable=False, default="pending")
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
