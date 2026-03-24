"""Authentication service."""

import secrets
import uuid
from datetime import date, datetime, timedelta
from typing import Optional

from jose import JWTError, jwt
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.logging import get_logger
from app.core.redis import get_redis
from app.modules.auth.models import User, UserRole

logger = get_logger(__name__)

# Durée de validité de l'OTP (5 minutes)
OTP_EXPIRY_SECONDS = 300
# Durée de validité du refresh token (7 jours)
REFRESH_TOKEN_EXPIRY_DAYS = 7
PROFILE_COMPLETION_FIELDS = (
    "first_name",
    "last_name",
    "country",
    "city",
    "address",
    "email",
    "gender",
    "date_of_birth",
)
REQUIRED_PROFILE_FIELDS = (
    "first_name",
    "last_name",
    "country",
    "city",
)
PROFILE_SECTION_FIELDS = {
    "identity": {
        "label": "Identite",
        "fields": ("first_name", "last_name", "date_of_birth", "gender"),
    },
    "contact": {
        "label": "Contact",
        "fields": ("phone_number", "email", "language"),
    },
    "location": {
        "label": "Localisation",
        "fields": ("country", "city", "address"),
    },
    "account": {
        "label": "Compte",
        "fields": ("role", "is_verified"),
    },
}


def _is_filled(value: object | None) -> bool:
    """Return True when a profile value is considered filled."""
    if value is None:
        return False
    if isinstance(value, str):
        return bool(value.strip())
    return True


def build_user_profile_payload(user: User) -> dict:
    """Serialize user profile with Makiti-specific completeness indicators."""
    missing_profile_fields = [
        field_name
        for field_name in PROFILE_COMPLETION_FIELDS
        if not _is_filled(getattr(user, field_name, None))
    ]
    filled_fields = len(PROFILE_COMPLETION_FIELDS) - len(missing_profile_fields)
    profile_completion = int((filled_fields / len(PROFILE_COMPLETION_FIELDS)) * 100)
    is_profile_complete = all(
        _is_filled(getattr(user, field_name, None))
        for field_name in REQUIRED_PROFILE_FIELDS
    )
    profile_sections = []
    for section_key, definition in PROFILE_SECTION_FIELDS.items():
        section_fields = definition["fields"]
        missing_fields = [
            field_name
            for field_name in section_fields
            if not _is_filled(getattr(user, field_name, None))
        ]
        filled_fields = len(section_fields) - len(missing_fields)
        completion = int((filled_fields / len(section_fields)) * 100)
        profile_sections.append(
            {
                "key": section_key,
                "label": definition["label"],
                "completion": completion,
                "is_complete": not missing_fields,
                "filled_fields": filled_fields,
                "total_fields": len(section_fields),
                "missing_fields": missing_fields,
            }
        )
    location_parts = [
        value.strip()
        for value in [user.city, user.country]
        if isinstance(value, str) and value.strip()
    ]

    return {
        "id": user.id,
        "phone_number": user.phone_number,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "full_name": user.full_name,
        "date_of_birth": user.date_of_birth,
        "email": user.email,
        "gender": user.gender,
        "country": user.country,
        "city": user.city,
        "address": user.address,
        "latitude": user.latitude,
        "longitude": user.longitude,
        "profile_picture_url": user.profile_picture_url,
        "language": user.language,
        "location_label": ", ".join(location_parts) if location_parts else None,
        "is_verified": user.is_verified,
        "is_active": user.is_active,
        "role": user.role,
        "is_seller_enabled": user.is_seller_enabled,
        "is_buyer_enabled": user.is_buyer_enabled,
        "is_box_owner_enabled": user.is_box_owner_enabled,
        "profile_completion": profile_completion,
        "is_profile_complete": is_profile_complete,
        "missing_profile_fields": missing_profile_fields,
        "profile_sections": profile_sections,
        "created_at": user.created_at,
        "updated_at": user.updated_at,
        "last_login": user.last_login,
    }


async def generate_otp(phone_number: str) -> str:
    """Generate and store OTP code (unified for login/register)."""
    otp_code = f"{secrets.randbelow(900000) + 100000:06d}"

    redis = await get_redis()
    key = f"otp:{phone_number}"
    await redis.setex(key, OTP_EXPIRY_SECONDS, otp_code)

    logger.info("OTP generated", phone_number=phone_number)
    if settings.DEBUG:
        logger.info(f"OTP code for {phone_number}: {otp_code}")

    return otp_code


async def verify_otp(phone_number: str, otp_code: str) -> bool:
    """Verify OTP code (unified for login/register)."""
    redis = await get_redis()
    key = f"otp:{phone_number}"
    stored_code = await redis.get(key)
    
    if not stored_code:
        logger.warning("OTP not found or expired", phone_number=phone_number)
        return False
    
    stored_code_str = stored_code.decode("utf-8") if isinstance(stored_code, bytes) else stored_code
    
    if stored_code_str != otp_code:
        logger.warning("OTP mismatch", phone_number=phone_number)
        return False
    
    logger.info("OTP verified successfully", phone_number=phone_number)
    return True


async def consume_otp(phone_number: str, otp_code: str) -> bool:
    """Verify and consume OTP code."""
    redis = await get_redis()
    key = f"otp:{phone_number}"
    stored_code = await redis.get(key)
    
    if not stored_code:
        logger.warning("OTP not found or expired", phone_number=phone_number)
        return False
    
    stored_code_str = stored_code.decode("utf-8") if isinstance(stored_code, bytes) else stored_code
    
    if stored_code_str != otp_code:
        logger.warning("OTP mismatch", phone_number=phone_number)
        return False
    
    await redis.delete(key)
    logger.info("OTP consumed successfully", phone_number=phone_number)
    return True


async def get_user_by_id(session: AsyncSession, user_id: str) -> Optional[User]:
    """Fetch a user by id."""
    result = await session.execute(
        select(User).where(User.id == user_id)
    )
    return result.scalar_one_or_none()


async def check_user_exists(
    session: AsyncSession,
    phone_number: str,
) -> tuple[Optional[User], Optional[str]]:
    """Check if a unified user exists by phone number."""
    result = await session.execute(
        select(User).where(User.phone_number == phone_number)
    )
    user = result.scalar_one_or_none()
    return (user, user.role) if user else (None, None)


async def create_user(
    session: AsyncSession,
    phone_number: str,
    first_name: str,
    last_name: str,
    role: str,
    email: Optional[str] = None,
    date_of_birth: Optional[date] = None,
    gender: Optional[str] = None,
    country: Optional[str] = None,
    city: Optional[str] = None,
    address: Optional[str] = None,
    language: Optional[str] = None,
) -> tuple[User, bool]:
    """Create a new unified user."""
    normalized_country = country.strip().upper() if country else "SN"
    normalized_city = city.strip() if city else None
    normalized_address = address.strip() if address else None

    if email:
        existing_email_user = await session.execute(
            select(User).where(User.email == email)
        )
        if existing_email_user.scalar_one_or_none():
            raise ValueError("Un compte existe déjà avec cet email.")

    full_name = f"{first_name} {last_name}".strip()
    user = User(
        id=f"user-{uuid.uuid4().hex[:12]}",
        phone_number=phone_number,
        first_name=first_name,
        last_name=last_name,
        full_name=full_name,
        email=email,
        date_of_birth=date_of_birth,
        gender=gender,
        country=normalized_country,
        city=normalized_city,
        address=normalized_address,
        language=language or "fr",
        role=role,
        is_verified=True,
        is_seller_enabled=role in {
            UserRole.SELLER.value,
            UserRole.BUYER_SELLER.value,
            UserRole.BOX_OWNER.value,
        },
        is_buyer_enabled=role in {
            UserRole.BUYER.value,
            UserRole.BUYER_SELLER.value,
            UserRole.BOX_OWNER.value,
        },
        is_box_owner_enabled=role == UserRole.BOX_OWNER.value,
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)
    logger.info("New user created", phone_number=phone_number, role=role)
    return user, True


async def login_user(
    session: AsyncSession,
    phone_number: str,
    full_name: Optional[str] = None,
) -> tuple[User, str]:
    """Login existing user."""
    user, role = await check_user_exists(session, phone_number)

    if not user or not role:
        raise ValueError("User not found")

    if full_name and not user.full_name:
        user.full_name = full_name
        await session.commit()

    user.last_login = datetime.utcnow()
    await session.commit()

    logger.info("User logged in", phone_number=phone_number, role=role)
    return user, role


async def update_profile(
    session: AsyncSession,
    user: User,
    *,
    first_name: Optional[str] = None,
    last_name: Optional[str] = None,
    email: Optional[str] = None,
    date_of_birth: Optional[date] = None,
    gender: Optional[str] = None,
    country: Optional[str] = None,
    city: Optional[str] = None,
    address: Optional[str] = None,
) -> User:
    """Update user profile."""
    if email is not None and email != user.email:
        existing = await session.execute(
            select(User).where(User.email == email)
        )
        if existing.scalar_one_or_none():
            raise ValueError("Un compte existe déjà avec cet email.")

    if first_name is not None:
        user.first_name = first_name
    if last_name is not None:
        user.last_name = last_name
    if email is not None:
        user.email = email
    if date_of_birth is not None:
        user.date_of_birth = date_of_birth
    if gender is not None:
        user.gender = gender
    if country is not None:
        user.country = country.strip().upper()
    if city is not None:
        user.city = city.strip() or None
    if address is not None:
        user.address = address.strip() or None

    fn = user.first_name or ""
    ln = user.last_name or ""
    user.full_name = f"{fn} {ln}".strip() or user.full_name

    await session.commit()
    await session.refresh(user)
    logger.info("Profile updated", user_id=str(user.id))
    return user


def create_access_token(user_id: str, role: str, phone_number: str) -> str:
    """Create JWT access token."""
    payload = {
        "sub": user_id,
        "type": "access",
        "role": role,
        "phone_number": phone_number,
        "exp": datetime.utcnow() + timedelta(hours=24),
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")


def create_refresh_token(user_id: str, role: str, phone_number: str) -> str:
    """Create JWT refresh token."""
    payload = {
        "sub": user_id,
        "type": "refresh",
        "role": role,
        "phone_number": phone_number,
        "exp": datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRY_DAYS),
    }
    return jwt.encode(payload, settings.SECRET_KEY, algorithm="HS256")


def verify_token(token: str) -> dict | None:
    """Verify and decode JWT token."""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
        return payload
    except JWTError:
        return None
