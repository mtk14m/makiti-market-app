"""Logistics API endpoints."""

from fastapi import APIRouter, Depends

from app.core.dependencies import DatabaseDep
from app.modules.auth.dependencies import get_current_operator
from app.modules.auth.models import User
from app.modules.logistics import schemas, service

router = APIRouter(prefix="/logistics", tags=["logistics"])


@router.get("/boxes", response_model=list[schemas.BoxResponse])
async def get_boxes(
    db: DatabaseDep = None,
) -> list[schemas.BoxResponse]:
    """List smart boxes."""
    boxes = await service.BoxService.list_boxes(db)
    return [schemas.BoxResponse.model_validate(item) for item in boxes]


@router.post("/boxes", response_model=schemas.BoxResponse, status_code=201)
async def create_box(
    payload: schemas.BoxCreate,
    operator: User = Depends(get_current_operator),
    db: DatabaseDep = None,
) -> schemas.BoxResponse:
    """Create a smart box."""
    del operator
    box = await service.BoxService.create(db, payload)
    return schemas.BoxResponse.model_validate(box)


@router.get("/parcels", response_model=list[schemas.ParcelResponse])
async def get_parcels(
    operator: User = Depends(get_current_operator),
    db: DatabaseDep = None,
) -> list[schemas.ParcelResponse]:
    """List parcels."""
    del operator
    parcels = await service.ParcelService.list_parcels(db)
    return [schemas.ParcelResponse.model_validate(item) for item in parcels]


@router.post("/parcels", response_model=schemas.ParcelResponse, status_code=201)
async def create_parcel(
    payload: schemas.ParcelCreate,
    operator: User = Depends(get_current_operator),
    db: DatabaseDep = None,
) -> schemas.ParcelResponse:
    """Create parcel."""
    del operator
    parcel = await service.ParcelService.create(db, payload)
    return schemas.ParcelResponse.model_validate(parcel)


@router.get("/shipments", response_model=list[schemas.ShipmentResponse])
async def get_shipments(
    operator: User = Depends(get_current_operator),
    db: DatabaseDep = None,
) -> list[schemas.ShipmentResponse]:
    """List shipments."""
    del operator
    shipments = await service.ShipmentService.list_shipments(db)
    return [schemas.ShipmentResponse.model_validate(item) for item in shipments]


@router.post("/shipments", response_model=schemas.ShipmentResponse, status_code=201)
async def create_shipment(
    payload: schemas.ShipmentCreate,
    operator: User = Depends(get_current_operator),
    db: DatabaseDep = None,
) -> schemas.ShipmentResponse:
    """Create shipment."""
    del operator
    shipment = await service.ShipmentService.create(db, payload)
    return schemas.ShipmentResponse.model_validate(shipment)
