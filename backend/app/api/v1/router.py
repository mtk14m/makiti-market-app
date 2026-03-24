"""API v1 router."""

from fastapi import APIRouter

from app.api.v1.endpoints import health
from app.modules.auth import endpoints as auth_endpoints
from app.modules.commerce import endpoints as commerce_endpoints
from app.modules.logistics import endpoints as logistics_endpoints

api_router = APIRouter()

# Include endpoint routers
api_router.include_router(health.router, prefix="/health", tags=["health"])
api_router.include_router(auth_endpoints.router, tags=["authentication"])
api_router.include_router(commerce_endpoints.router)
api_router.include_router(logistics_endpoints.router)

