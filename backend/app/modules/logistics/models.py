"""Logistics domain models."""

from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, Float, Integer, String

from app.core.database import Base


class Box(Base):
    """Smart locker hub."""

    __tablename__ = "boxes"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    city = Column(String, nullable=False, index=True)
    zone = Column(String, nullable=False, index=True)
    address = Column(String, nullable=True)
    latitude = Column(String, nullable=True)
    longitude = Column(String, nullable=True)
    owner_user_id = Column(String, nullable=True, index=True)
    status = Column(String, nullable=False, default="active", index=True)
    total_lockers = Column(Integer, nullable=False, default=0)
    available_lockers = Column(Integer, nullable=False, default=0)
    supports_transit = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Parcel(Base):
    """Parcel generated after a commerce order."""

    __tablename__ = "parcels"

    id = Column(String, primary_key=True, index=True)
    order_id = Column(String, nullable=False, unique=True, index=True)
    listing_id = Column(String, nullable=False, index=True)
    seller_id = Column(String, nullable=False, index=True)
    buyer_id = Column(String, nullable=False, index=True)
    origin_box_id = Column(String, nullable=True, index=True)
    destination_box_id = Column(String, nullable=True, index=True)
    current_box_id = Column(String, nullable=True, index=True)
    parcel_size = Column(String, nullable=False, default="M")
    delivery_mode = Column(String, nullable=False, default="same_zone", index=True)
    status = Column(String, nullable=False, default="awaiting_dropoff", index=True)
    locker_state = Column(String, nullable=False, default="reserved_for_deposit", index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Shipment(Base):
    """Box-to-box transfer of one or more parcels."""

    __tablename__ = "shipments"

    id = Column(String, primary_key=True, index=True)
    parcel_id = Column(String, nullable=False, index=True)
    origin_box_id = Column(String, nullable=True, index=True)
    destination_box_id = Column(String, nullable=True, index=True)
    route_code = Column(String, nullable=True, index=True)
    vehicle_code = Column(String, nullable=True, index=True)
    status = Column(String, nullable=False, default="planned", index=True)
    distance_km = Column(Float, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
