"""Authentication Pydantic schemas."""

from datetime import date, datetime
from typing import Optional

from pydantic import ConfigDict, EmailStr, Field, field_validator

from app.core.schemas import BaseSchema
from app.modules.auth.models import UserRole


class SendOTPRequest(BaseSchema):
    """Schema for sending OTP (unified for login/register)."""

    phone_number: str = Field(..., min_length=8, max_length=20, description="Numéro de téléphone")

    @field_validator("phone_number")
    @classmethod
    def validate_phone_number(cls, v: str) -> str:
        """Validate and normalize phone number."""
        # Retirer les espaces, tirets, parenthèses
        cleaned = v.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
        # Ajouter l'indicatif +221 si absent (Sénégal par défaut)
        if not cleaned.startswith("+"):
            if cleaned.startswith("221"):
                cleaned = "+" + cleaned
            elif cleaned.startswith("0"):
                cleaned = "+221" + cleaned[1:]
            else:
                cleaned = "+221" + cleaned
        return cleaned


class VerifyOTPRequest(BaseSchema):
    """Schema for verifying OTP (unified for login/register)."""

    phone_number: str = Field(..., min_length=8, max_length=20)
    otp_code: str = Field(..., min_length=4, max_length=6, description="Code OTP")

    @field_validator("phone_number")
    @classmethod
    def validate_phone_number(cls, v: str) -> str:
        """Validate and normalize phone number."""
        cleaned = v.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
        if not cleaned.startswith("+"):
            if cleaned.startswith("221"):
                cleaned = "+" + cleaned
            elif cleaned.startswith("0"):
                cleaned = "+221" + cleaned[1:]
            else:
                cleaned = "+221" + cleaned
        return cleaned


class RegisterRequest(BaseSchema):
    """Schema for completing registration after OTP verification."""

    phone_number: str = Field(..., min_length=8, max_length=20)
    first_name: str = Field(..., min_length=1, max_length=100, description="Prénom")
    last_name: str = Field(..., min_length=1, max_length=100, description="Nom")
    role: str = Field(
        default=UserRole.BUYER_SELLER.value,
        description="buyer, seller, buyer_seller, operator, box_owner ou admin",
    )
    email: Optional[EmailStr] = Field(None, description="Email")
    date_of_birth: Optional[date] = Field(None, description="Date de naissance")
    gender: Optional[str] = Field(None, description="Genre: 'male' ou 'female'")
    country: str = Field(..., min_length=2, max_length=10, description="Code pays ISO (ex: SN)")
    city: str = Field(..., min_length=2, max_length=100, description="Ville")
    address: Optional[str] = Field(None, description="Adresse complète")
    language: str = Field(default="fr", description="Code langue ISO")

    @field_validator("phone_number")
    @classmethod
    def validate_phone_number(cls, v: str) -> str:
        """Validate and normalize phone number."""
        cleaned = v.replace(" ", "").replace("-", "").replace("(", "").replace(")", "")
        if not cleaned.startswith("+"):
            if cleaned.startswith("221"):
                cleaned = "+" + cleaned
            elif cleaned.startswith("0"):
                cleaned = "+221" + cleaned[1:]
            else:
                cleaned = "+221" + cleaned
        return cleaned

    @field_validator("role")
    @classmethod
    def validate_role(cls, v: str) -> str:
        """Validate role."""
        v_lower = v.lower()
        allowed_roles = {role.value for role in UserRole}
        if v_lower not in allowed_roles:
            raise ValueError(f"role must be one of: {', '.join(sorted(allowed_roles))}")
        return v_lower

    @field_validator("gender")
    @classmethod
    def validate_gender(cls, v: Optional[str]) -> Optional[str]:
        """Validate gender."""
        if v is None:
            return None
        v_lower = v.lower()
        if v_lower not in ["male", "female"]:
            raise ValueError("gender must be 'male' or 'female'")
        return v_lower


class SendOTPResponse(BaseSchema):
    """Schema for send OTP response."""

    message: str
    phone_number: str
    expires_in: int
    otp_code: str  # Retourné en développement pour faciliter les tests


class VerifyOTPResponse(BaseSchema):
    """Schema for verify OTP response (indicates if user exists)."""

    user_exists: bool
    role: Optional[str] = None
    phone_number: str


class TokenResponse(BaseSchema):
    """Schema for token response."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: str
    role: str
    phone_number: str
    is_new_user: bool = False


class RefreshTokenRequest(BaseSchema):
    """Schema for refreshing token."""

    refresh_token: str = Field(..., description="Refresh token")


class UpdateProfileRequest(BaseSchema):
    """Schema for updating user profile."""

    first_name: Optional[str] = Field(None, min_length=1, max_length=100)
    last_name: Optional[str] = Field(None, min_length=1, max_length=100)
    email: Optional[EmailStr] = Field(None)
    date_of_birth: Optional[date] = Field(None)
    gender: Optional[str] = Field(None, description="Genre: 'male' ou 'female'")
    country: Optional[str] = Field(None, max_length=10)
    city: Optional[str] = Field(None, max_length=100)
    address: Optional[str] = Field(None)

    @field_validator("gender")
    @classmethod
    def validate_gender(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return None
        v_lower = v.lower()
        if v_lower not in ["male", "female"]:
            raise ValueError("gender must be 'male' or 'female'")
        return v_lower


class ProfileSectionSummary(BaseSchema):
    """Progress summary for a logical user-profile section."""

    key: str
    label: str
    completion: int
    is_complete: bool
    filled_fields: int
    total_fields: int
    missing_fields: list[str] = Field(default_factory=list)


class UserResponse(BaseSchema):
    """Schema for user response."""

    id: str
    phone_number: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    full_name: Optional[str] = None  # Conservé pour compatibilité
    date_of_birth: Optional[date] = None
    email: Optional[str] = None
    gender: Optional[str] = None
    country: Optional[str] = None
    city: Optional[str] = None
    address: Optional[str] = None
    latitude: Optional[str] = None
    longitude: Optional[str] = None
    profile_picture_url: Optional[str] = None
    language: Optional[str] = None
    location_label: Optional[str] = None
    is_verified: bool
    is_active: bool
    role: str
    is_seller_enabled: bool
    is_buyer_enabled: bool
    is_box_owner_enabled: bool
    profile_completion: int
    is_profile_complete: bool
    missing_profile_fields: list[str] = Field(default_factory=list)
    profile_sections: list[ProfileSectionSummary] = Field(default_factory=list)
    created_at: datetime
    updated_at: Optional[datetime] = None
    last_login: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
