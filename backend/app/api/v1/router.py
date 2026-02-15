"""API v1 router."""

from fastapi import APIRouter

from app.api.v1.endpoints import health
from app.modules.products import endpoints as products_endpoints

api_router = APIRouter()

# Include endpoint routers
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(
    products_endpoints.router, prefix="/products", tags=["products"]
)


