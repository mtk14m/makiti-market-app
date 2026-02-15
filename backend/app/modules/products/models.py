"""Product models."""

from datetime import datetime
from typing import Optional

from sqlalchemy import Column, String, Float, Boolean, DateTime, Text

from app.core.database import Base


class Product(Base):
    """Product model."""

    __tablename__ = "products"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    description = Column(Text, nullable=True)
    price = Column(Float, nullable=False)  # Prix en FCFA
    original_price = Column(Float, nullable=True)  # Prix avant réduction
    image_url = Column(String, nullable=True)
    category = Column(String, nullable=False, index=True)
    unit = Column(String, nullable=True)  # kg, L, pièce, etc.
    is_available = Column(Boolean, default=True, index=True)
    
    # Prix de référence pour négociation (côté shopper)
    price_min = Column(Float, nullable=True)  # P_min
    price_target = Column(Float, nullable=True)  # P_target
    price_max = Column(Float, nullable=True)  # P_max
    
    # Métadonnées
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self) -> str:
        """String representation."""
        return f"<Product(id={self.id}, name={self.name}, price={self.price})>"

