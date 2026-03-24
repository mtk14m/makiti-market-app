"""Authentication and identity models."""

from datetime import datetime
from enum import Enum

from sqlalchemy import Boolean, Column, Date, DateTime, Enum as SQLEnum, String, Text

from app.core.database import Base


class UserRole(str, Enum):
    """Unified platform roles."""

    BUYER = "buyer"
    SELLER = "seller"
    BUYER_SELLER = "buyer_seller"
    OPERATOR = "operator"
    BOX_OWNER = "box_owner"
    ADMIN = "admin"


class User(Base):
    """Unified Makiti user model."""

    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)
    phone_number = Column(String, nullable=False, unique=True, index=True)
    first_name = Column(String, nullable=True)
    last_name = Column(String, nullable=True)
    full_name = Column(String, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    email = Column(String, nullable=True, unique=True, index=True)
    gender = Column(String, nullable=True)
    country = Column(String, nullable=True, default="SN")
    city = Column(String, nullable=True)
    address = Column(Text, nullable=True)
    latitude = Column(String, nullable=True)
    longitude = Column(String, nullable=True)
    profile_picture_url = Column(String, nullable=True)
    language = Column(String, nullable=True, default="fr")
    role = Column(
        SQLEnum(
            UserRole,
            name="userrole",
            native_enum=False,
            values_callable=lambda enum_cls: [member.value for member in enum_cls],
        ),
        default=UserRole.BUYER_SELLER.value,
        nullable=False,
    )
    is_verified = Column(Boolean, default=False, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_seller_enabled = Column(Boolean, default=True, nullable=False)
    is_buyer_enabled = Column(Boolean, default=True, nullable=False)
    is_box_owner_enabled = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = Column(DateTime, nullable=True)

    def __repr__(self) -> str:
        """String representation."""
        return f"<User(id={self.id}, phone_number={self.phone_number}, role={self.role})>"
