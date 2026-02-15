"""Base Pydantic schemas."""

from datetime import datetime
from typing import Any, Generic, TypeVar

from pydantic import BaseModel, ConfigDict

T = TypeVar("T")


class BaseSchema(BaseModel):
    """Base schema with common configuration."""

    model_config = ConfigDict(
        from_attributes=True,
        validate_assignment=True,
        str_strip_whitespace=True,
    )


class TimestampSchema(BaseSchema):
    """Schema with timestamp fields."""

    created_at: datetime
    updated_at: datetime | None = None


class ResponseSchema(BaseSchema):
    """Base response schema."""

    success: bool = True
    message: str | None = None
    data: Any | None = None


class PaginationParams(BaseSchema):
    """Pagination parameters."""

    page: int = 1
    page_size: int = 20

    @property
    def skip(self) -> int:
        """Calculate skip value."""
        return (self.page - 1) * self.page_size

    @property
    def limit(self) -> int:
        """Get limit value."""
        return self.page_size


class PaginatedResponse(BaseSchema, Generic[T]):
    """Paginated response schema."""

    items: list[T]
    total: int
    page: int
    page_size: int
    pages: int

    @property
    def has_next(self) -> bool:
        """Check if there is a next page."""
        return self.page < self.pages

    @property
    def has_prev(self) -> bool:
        """Check if there is a previous page."""
        return self.page > 1


