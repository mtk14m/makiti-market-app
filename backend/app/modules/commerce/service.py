"""Commerce services."""

import json
from uuid import uuid4

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundError
from app.core.schemas import PaginationParams
from app.modules.auth.models import User
from app.modules.commerce.models import Listing, ListingStatus, OrderStatus, PurchaseOrder
from app.modules.commerce.schemas import ListingCreate, ListingUpdate, OrderCreate


class ListingService:
    """Listing operations."""

    @staticmethod
    async def get_all(
        db: AsyncSession,
        pagination: PaginationParams,
        category: str | None = None,
        search: str | None = None,
        seller_id: str | None = None,
        status: str | None = ListingStatus.PUBLISHED.value,
    ) -> tuple[list[Listing], int]:
        """List listings with filters."""
        query = select(Listing)
        if category:
            query = query.where(Listing.category == category)
        if seller_id:
            query = query.where(Listing.seller_id == seller_id)
        if status:
            query = query.where(Listing.status == status)
        if search:
            search_term = f"%{search.lower()}%"
            query = query.where(
                Listing.title.ilike(search_term) | Listing.description.ilike(search_term)
            )

        total = (
            await db.execute(select(func.count()).select_from(query.subquery()))
        ).scalar_one()
        result = await db.execute(
            query.order_by(Listing.created_at.desc()).offset(pagination.skip).limit(pagination.limit)
        )
        return list(result.scalars().all()), total

    @staticmethod
    async def get_by_id(db: AsyncSession, listing_id: str) -> Listing:
        """Get a listing by id."""
        result = await db.execute(select(Listing).where(Listing.id == listing_id))
        listing = result.scalar_one_or_none()
        if not listing:
            raise NotFoundError("Listing")
        return listing

    @staticmethod
    async def create(db: AsyncSession, seller: User, payload: ListingCreate) -> Listing:
        """Create a listing."""
        listing = Listing(
            id=f"lst-{uuid4().hex[:12]}",
            seller_id=seller.id,
            photo_urls=json.dumps(payload.photo_urls),
            **payload.model_dump(exclude={"photo_urls"}),
        )
        db.add(listing)
        await db.commit()
        await db.refresh(listing)
        return listing

    @staticmethod
    async def update(db: AsyncSession, listing_id: str, payload: ListingUpdate) -> Listing:
        """Update a listing."""
        listing = await ListingService.get_by_id(db, listing_id)
        update_data = payload.model_dump(exclude_unset=True)
        if "photo_urls" in update_data and update_data["photo_urls"] is not None:
            update_data["photo_urls"] = json.dumps(update_data["photo_urls"])
        for field, value in update_data.items():
            setattr(listing, field, value)
        await db.commit()
        await db.refresh(listing)
        return listing


class OrderService:
    """Commerce order operations."""

    @staticmethod
    async def create(db: AsyncSession, buyer: User, payload: OrderCreate) -> PurchaseOrder:
        """Create an order from a listing."""
        listing = await ListingService.get_by_id(db, payload.listing_id)
        if listing.status != ListingStatus.PUBLISHED.value:
            raise ValueError("Cette annonce n'est plus disponible.")

        buyer_fee = round(listing.price * 0.05 + 300, 2)
        logistics_fee = 1000.0
        platform_fee = round(listing.price * 0.03, 2)
        order = PurchaseOrder(
            id=f"ord-{uuid4().hex[:12]}",
            listing_id=listing.id,
            buyer_id=buyer.id,
            seller_id=listing.seller_id,
            buyer_box_id=payload.buyer_box_id,
            seller_box_id=payload.seller_box_id or listing.seller_box_id,
            status=OrderStatus.PAID.value,
            item_price=listing.price,
            buyer_fee=buyer_fee,
            logistics_fee=logistics_fee,
            platform_fee=platform_fee,
            total_amount=listing.price + buyer_fee + logistics_fee,
            currency=listing.currency,
            payment_status="authorized",
            escrow_status="held",
        )
        listing.status = ListingStatus.RESERVED.value
        db.add(order)
        await db.commit()
        await db.refresh(order)
        return order
