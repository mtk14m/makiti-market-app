"""Authentication endpoints."""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.logging import get_logger
from app.core.redis import get_redis
from app.modules.auth import schemas, service
from app.modules.auth.dependencies import get_current_user
from app.modules.auth.models import User

logger = get_logger(__name__)

router = APIRouter(prefix="/auth", tags=["authentication"])


@router.post("/send-otp", response_model=schemas.SendOTPResponse)
async def send_otp(
    request: schemas.SendOTPRequest,
    db: AsyncSession = Depends(get_db),
):
    """Generate OTP code (unified for login/register)."""
    try:
        otp_code = await service.generate_otp(request.phone_number)
        
        return schemas.SendOTPResponse(
            message="Code OTP généré avec succès",
            phone_number=request.phone_number,
            expires_in=service.OTP_EXPIRY_SECONDS,
            otp_code=otp_code,
        )
    except Exception as e:
        logger.error("Failed to generate OTP", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la génération du code OTP"
        )


@router.post("/verify-otp", response_model=schemas.VerifyOTPResponse)
async def verify_otp(
    request: schemas.VerifyOTPRequest,
    db: AsyncSession = Depends(get_db),
):
    """Verify OTP and check if user exists."""
    is_valid = await service.verify_otp(request.phone_number, request.otp_code)

    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Code OTP invalide ou expiré"
        )

    user, role = await service.check_user_exists(db, request.phone_number)

    if user:
        return schemas.VerifyOTPResponse(
            user_exists=True,
            role=role,
            phone_number=request.phone_number,
        )

    return schemas.VerifyOTPResponse(
        user_exists=False,
        role=None,
        phone_number=request.phone_number,
    )


@router.post("/register", response_model=schemas.TokenResponse)
async def register(
    request: schemas.RegisterRequest,
    db: AsyncSession = Depends(get_db),
):
    """Complete registration after OTP verification and return tokens."""
    existing_user, existing_role = await service.check_user_exists(db, request.phone_number)

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Un compte existe déjà avec ce numéro (rôle: {existing_role})"
        )

    try:
        user, _ = await service.create_user(
            session=db,
            phone_number=request.phone_number,
            first_name=request.first_name,
            last_name=request.last_name,
            role=request.role,
            email=request.email,
            date_of_birth=request.date_of_birth,
            gender=request.gender,
            country=request.country,
            city=request.city,
            address=request.address,
            language=request.language,
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    redis = await get_redis()
    await redis.delete(f"otp:{request.phone_number}")

    user_id = user.id
    access_token = service.create_access_token(user_id, request.role, request.phone_number)
    refresh_token = service.create_refresh_token(user_id, request.role, request.phone_number)

    return schemas.TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user_id=user_id,
        role=request.role,
        phone_number=request.phone_number,
        is_new_user=True,
    )


@router.post("/login", response_model=schemas.TokenResponse)
async def login(
    request: schemas.VerifyOTPRequest,
    db: AsyncSession = Depends(get_db),
):
    """Login existing user after OTP verification."""
    is_valid = await service.consume_otp(request.phone_number, request.otp_code)

    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Code OTP invalide ou expiré"
        )

    try:
        user, role = await service.login_user(db, request.phone_number)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Utilisateur introuvable. Veuillez vous inscrire."
        )

    user_id = user.id
    access_token = service.create_access_token(user_id, role, request.phone_number)
    refresh_token = service.create_refresh_token(user_id, role, request.phone_number)

    return schemas.TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user_id=user_id,
        role=role,
        phone_number=request.phone_number,
        is_new_user=False,
    )


@router.post("/refresh", response_model=schemas.TokenResponse)
async def refresh_token(
    request: schemas.RefreshTokenRequest,
    db: AsyncSession = Depends(get_db),
):
    """Refresh access token using refresh token."""
    payload = service.verify_token(request.refresh_token)

    if not payload or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token invalide"
        )

    user_id = payload.get("sub")
    role = payload.get("role")
    phone_number = payload.get("phone_number")

    if not all([user_id, role, phone_number]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide"
        )

    user = await service.get_user_by_id(db, user_id)

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Utilisateur introuvable ou inactif"
        )

    access_token = service.create_access_token(user_id, role, phone_number)
    refresh_token = service.create_refresh_token(user_id, role, phone_number)

    return schemas.TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user_id=user_id,
        role=role,
        phone_number=phone_number,
        is_new_user=False,
    )


@router.get("/me", response_model=schemas.UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
):
    """Get current authenticated user profile."""
    return schemas.UserResponse.model_validate(
        service.build_user_profile_payload(current_user)
    )


@router.patch("/me", response_model=schemas.UserResponse)
async def update_current_user_profile(
    request: schemas.UpdateProfileRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update current authenticated user profile."""
    try:
        updated = await service.update_profile(
            session=db,
            user=current_user,
            first_name=request.first_name,
            last_name=request.last_name,
            email=request.email,
            date_of_birth=request.date_of_birth,
            gender=request.gender,
            country=request.country,
            city=request.city,
            address=request.address,
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )
    return schemas.UserResponse.model_validate(
        service.build_user_profile_payload(updated)
    )
