"""Logistics services."""

from uuid import uuid4

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.modules.logistics.models import Box, Parcel, Shipment
from app.modules.logistics.schemas import BoxCreate, ParcelCreate, ShipmentCreate


class BoxService:
    """Box operations."""

    @staticmethod
    async def list_boxes(db: AsyncSession) -> list[Box]:
        """Return all boxes."""
        result = await db.execute(select(Box).order_by(Box.city.asc(), Box.name.asc()))
        return list(result.scalars().all())

    @staticmethod
    async def create(db: AsyncSession, payload: BoxCreate) -> Box:
        """Create a smart locker box."""
        box = Box(
            id=f"box-{uuid4().hex[:10]}",
            **payload.model_dump(),
        )
        db.add(box)
        await db.commit()
        await db.refresh(box)
        return box


class ParcelService:
    """Parcel operations."""

    @staticmethod
    async def list_parcels(db: AsyncSession) -> list[Parcel]:
        """Return all parcels."""
        result = await db.execute(select(Parcel).order_by(Parcel.created_at.desc()))
        return list(result.scalars().all())

    @staticmethod
    async def create(db: AsyncSession, payload: ParcelCreate) -> Parcel:
        """Create parcel."""
        delivery_mode = payload.delivery_mode
        status = "ready_for_buyer_pickup" if (
            payload.origin_box_id and payload.origin_box_id == payload.destination_box_id
        ) else "awaiting_dropoff"
        locker_state = "ready_for_buyer_pickup" if status == "ready_for_buyer_pickup" else "reserved_for_deposit"
        parcel = Parcel(
            id=f"par-{uuid4().hex[:12]}",
            status=status,
            locker_state=locker_state,
            delivery_mode=delivery_mode,
            **payload.model_dump(exclude={"delivery_mode"}),
        )
        db.add(parcel)
        await db.commit()
        await db.refresh(parcel)
        return parcel


class ShipmentService:
    """Shipment operations."""

    @staticmethod
    async def list_shipments(db: AsyncSession) -> list[Shipment]:
        """Return all shipments."""
        result = await db.execute(select(Shipment).order_by(Shipment.created_at.desc()))
        return list(result.scalars().all())

    @staticmethod
    async def create(db: AsyncSession, payload: ShipmentCreate) -> Shipment:
        """Create shipment."""
        shipment = Shipment(
            id=f"shp-{uuid4().hex[:12]}",
            status="planned",
            **payload.model_dump(),
        )
        db.add(shipment)
        await db.commit()
        await db.refresh(shipment)
        return shipment
