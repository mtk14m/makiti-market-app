"""Commerce API endpoints."""

import json
import uuid

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile, status

from app.core.dependencies import DatabaseDep
from app.core.schemas import PaginationParams
from app.core.storage import upload_image
from app.modules.auth.dependencies import get_current_buyer, get_current_seller
from app.modules.auth.models import User
from app.modules.commerce import schemas, service

router = APIRouter(prefix="/commerce", tags=["commerce"])


def _to_response(listing) -> schemas.ListingResponse:
    """Convert db listing to API response."""
    photo_urls = json.loads(listing.photo_urls) if listing.photo_urls else []
    return schemas.ListingResponse.model_validate(
        {
            **listing.__dict__,
            "photo_urls": photo_urls,
        }
    )


@router.get("/listings", response_model=schemas.ListingListResponse)
async def get_listings(
    pagination: PaginationParams = Depends(),
    category: str | None = Query(None),
    search: str | None = Query(None),
    seller_id: str | None = Query(None),
    status: str | None = Query("published"),
    db: DatabaseDep = None,
) -> schemas.ListingListResponse:
    """List marketplace listings."""
    items, total = await service.ListingService.get_all(
        db=db,
        pagination=pagination,
        category=category,
        search=search,
        seller_id=seller_id,
        status=status,
    )
    total_pages = (total + pagination.page_size - 1) // pagination.page_size
    return schemas.ListingListResponse(
        items=[_to_response(item) for item in items],
        total=total,
        page=pagination.page,
        page_size=pagination.page_size,
        pages=total_pages,
    )


@router.get("/listings/{listing_id}", response_model=schemas.ListingResponse)
async def get_listing(
    listing_id: str,
    db: DatabaseDep = None,
) -> schemas.ListingResponse:
    """Get listing details."""
    return _to_response(await service.ListingService.get_by_id(db, listing_id))


@router.post("/listings", response_model=schemas.ListingResponse, status_code=201)
async def create_listing(
    payload: schemas.ListingCreate,
    seller: User = Depends(get_current_seller),
    db: DatabaseDep = None,
) -> schemas.ListingResponse:
    """Create a seller listing."""
    listing = await service.ListingService.create(db, seller, payload)
    return _to_response(listing)


@router.patch("/listings/{listing_id}", response_model=schemas.ListingResponse)
async def update_listing(
    listing_id: str,
    payload: schemas.ListingUpdate,
    db: DatabaseDep = None,
) -> schemas.ListingResponse:
    """Update a listing."""
    listing = await service.ListingService.update(db, listing_id, payload)
    return _to_response(listing)


@router.post(
    "/listings/upload-image",
    response_model=schemas.ListingImageUploadResponse,
    status_code=201,
)
async def upload_listing_image(
    image: UploadFile = File(...),
    seller: User = Depends(get_current_seller),
) -> schemas.ListingImageUploadResponse:
    """Upload a listing image to storage and return its public URL."""
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Le fichier doit être une image valide",
        )

    file_data = await image.read()
    if not file_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Le fichier image est vide",
        )

    extension = "jpg"
    if image.filename and "." in image.filename:
        extension = image.filename.rsplit(".", 1)[-1].lower()

    object_name = f"listings/{seller.id}/{uuid.uuid4().hex}.{extension}"
    url = await upload_image(
        file_data=file_data,
        object_name=object_name,
        content_type=image.content_type,
    )
    return schemas.ListingImageUploadResponse(
        url=url,
        object_name=object_name,
    )


@router.post("/orders", response_model=schemas.OrderResponse, status_code=201)
async def create_order(
    payload: schemas.OrderCreate,
    buyer: User = Depends(get_current_buyer),
    db: DatabaseDep = None,
) -> schemas.OrderResponse:
    """Create a commerce order."""
    order = await service.OrderService.create(db, buyer, payload)
    return schemas.OrderResponse.model_validate(order)
